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
  @connecting = File.read("#{File.dirname(__FILE__)}/Connecting.png", mode: "rb")
  @current_image = @connecting
  @partial_image = ""
  @image = image @current_image
  @key_bindings = {}
  @key_states = {}

  @text = "NO KEY is PRESSED."

  @ardrone = ArDrone.new()

  @pressed_keys = Set.new

  def stream
    unless @pid && Process.waitpid(@pid, Process::WNOHANG)
      @ffmpeg = nil
      @pid = nil
      @current_image = @connecting
    end

    @ffmpeg ||= IO.popen(["ffmpeg",
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
    @pid = @ffmpeg.pid
    @ffmpeg
  end

  Thread.abort_on_exception = true
  Thread.new { Artoo::Robot.work!([@ardrone]) }
  Thread.new do
    loop do
      begin
        input = stream.read(100000)
        images = input.split(/(?=\x89PNG)/n)

        if images.length == 1
          #puts "found fragment"
          upcoming_image_fragment = images.first
          @partial_image << upcoming_image_fragment
        elsif images.length == 2
          #puts "completed image"

          end_of_upcoming_image, upcoming_image_fragment = images
          @partial_image << end_of_upcoming_image

          @current_image = @partial_image

          @partial_image = upcoming_image_fragment
        elsif images.length > 2
          #puts "found full image"

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

  def toggle(key, *options)
    @key_states[key] = options.first
    number_of_options = options.length
    @key_bindings[key] = {
      press: -> {
        current_state = @key_states[key]
        next_index = (options.index(current_state) + 1) % number_of_options
        option = @key_states[key] = options[next_index]
        drone.send(option)
      }
    }
  end

  def command(key, command)
    @key_bindings[key] = {
      press: -> {
        drone.send(command)
      }
    }
  end

  def movement(key, command, speed)
    @key_bindings[key] = {
      press: -> {
        drone.send(command, speed)
      },
      up: -> {
        drone.send(command, 0)
      }
    }
  end

  def handle_keypress(key)
    if @key_bindings[key] && (command = @key_bindings[key][:press])
      command.call
    end
  end

  def handle_keyup(key)
    if @key_bindings[key] && (command = @key_bindings[key][:up])
      command.call
    end
  end

  toggle 'c', :front_camera, :bottom_camera
  command 't', :take_off
  command 'g', :land
  command ' ', :emergency
  movement :up, :up, 0.3
  movement :down, :down, 0.3
  movement :left, :turn_left, 0.6
  movement :right, :turn_right, 0.6
  movement 'w', :forward, 0.3
  movement 's', :backward, 0.3
  movement 'a', :left, 0.3
  movement 'd', :right, 0.3

  keypress do |k|
    handle_keypress k

    @pressed_keys << k
    update_info
  end

  keyrelease do |k|
    handle_keyup k

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