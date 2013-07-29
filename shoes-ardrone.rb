require 'shoes/swt'

Dir.chdir(File.dirname(__FILE__)) do
  require 'bundler'
  Bundler.require
end

class ArDrone < Artoo::Robot
  connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
  device :drone, :driver => :ardrone, :connection => :ardrone

  work do
    drone.start
  end
end

Shoes.app do
  @current_image = nil
  @upcoming_image = ""

  @text = "NO KEY is PRESSED."

  def current_image_as_image_data
    return @current_image if @current_image.nil?
    input = @current_image
    stream = java.io.ByteArrayInputStream.new(input.to_java_bytes)
    begin
      org.eclipse.swt.graphics.ImageLoader.new().load(stream).first
    rescue org.eclipse.swt.SWTException
      nil
    end
  end

  def current_image
    Dir["#{File.dirname(__FILE__)}/images/*.png"].sort_by { |f| File.mtime f }.last
  end

  @ardrone = ArDrone.new()

  @pressed_keys = Set.new

  Thread.new { Artoo::Robot.work!([@ardrone]) }
  Thread.new do
    stream = IO.popen(["ffmpeg",
                       "-i",
                       "tcp://192.168.1.1:5555",
                       "-f",
                       "image2pipe",
                       "-vcodec",
                       "png",
                       "-"],
                       :external_encoding => "binary")

    loop do
      input = stream.read(100000)
      puts "read #{input.length}"
      images = input.split(/(?=\x89PNG)/n)

      if images.length == 1
        puts "found fragment"
        upcoming_image_fragment = images.first
        @upcoming_image << upcoming_image_fragment
      else
        puts "found new image"

        end_of_upcoming_image, upcoming_image_fragment = images[-2..-1]
        @upcoming_image << end_of_upcoming_image

        @current_image = @upcoming_image
        File.open("debug.png", "wb") do |f|
          f.write @current_image
        end
        @upcoming_image = upcoming_image_fragment
      end
    end
  end

  keypress do |k|
    puts "pressed #{k}"

    drone.take_off if k == 't'
    drone.land if k == 'g'

    drone.up 0.3 if k == :up
    drone.down 0.3 if k == :down
    drone.turn_left 0.6 if k == :left
    drone.turn_right 0.6 if k == :right
    drone.forward 0.3 if k == 'w'
    drone.backward 0.3 if k == 's'
    drone.left 0.3 if k == 'a'
    drone.right 0.3 if k == 'd'

    drone.emergency if k == " "
    @pressed_keys << k
    update_info
  end

  keyrelease do |k|
    puts "released #{k}"

    drone.up 0 if k == :up
    drone.down 0 if k == :down
    drone.turn_left 0 if k == :left
    drone.turn_right 0 if k == :right
    drone.forward 0 if k == 'w'
    drone.backward 0 if k == 's'
    drone.left 0 if k == 'a'
    drone.right 0 if k == 'd'

    @pressed_keys.delete k
    update_info
  end

  def update_info
    @text = "#{@pressed_keys.inspect} are PRESSED."
  end

  def drone
    @ardrone.drone
  end

  flow do
    @para = para @text
    animate(8) do
      #puts "replacing image with #{image}"
      #@para = para @text unless @para
      @para.replace @text
      if current_image_data = current_image_as_image_data
        puts "displaying image #{current_image_data.inspect}"
        @image = image current_image_as_image_data
      end
    end
  end
end