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
  @current_image = File.read("#{File.dirname(__FILE__)}/Connecting.png", mode: "rb")
  @partial_image = ""
  @image = image @current_image

  @text = "NO KEY is PRESSED."

  @ardrone = ArDrone.new()

  @pressed_keys = Set.new

  Thread.abort_on_exception = true
  Thread.new { Artoo::Robot.work!([@ardrone]) }
  Thread.new do
    stream = IO.popen(["ffmpeg",
                       "-i",
                       "tcp://192.168.1.1:5555",
                       "-f",
                       "image2pipe",
                       "-vcodec",
                       "png",
                       "-r",
                       "8",
                       "-"],
                       :external_encoding => "binary")

    loop do
      begin
        input = stream.read(100000)
        images = input.split(/(?=\x89PNG)/n)

        if images.length == 1
          puts "found fragment"
          upcoming_image_fragment = images.first
          @partial_image << upcoming_image_fragment
        elsif images.length == 2
          puts "completed image"

          end_of_upcoming_image, upcoming_image_fragment = images
          @partial_image << end_of_upcoming_image

          @current_image = @partial_image

          @partial_image = upcoming_image_fragment
        elsif images.length > 2
          puts "found full image"

          full_image, upcoming_image_fragment = images[-2..-1]
          @current_image = full_image

          @partial_image = upcoming_image_fragment
        end
        File.open("debug.png", "wb") do |f|
          f.write @current_image
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
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

  animate(8) do
    @image.path = @current_image
  end
end