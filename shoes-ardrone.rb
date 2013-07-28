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
  @ardrone = ArDrone.new()

  @pressed_keys = Set.new

  @info = para "NO KEY is PRESSED."

  #button "start" do
    Thread.new { Artoo::Robot.work!([@ardrone]) }
    #end

  keypress do |k|
    drone.take_off if k == 't'
    drone.land if k == 'g'

    drone.up 0.3 if k == :up
    drone.down 0.3 if k == :down
    drone.turn_left 0.3 if k == :left
    drone.turn_right 0.3 if k == :right
    drone.forward 0.3 if k == 'w'
    drone.backward 0.3 if k == 's'
    drone.left 0.3 if k == 'a'
    drone.right 0.3 if k == 'd'

    drone.emergency if k == " "
    @pressed_keys << k
    update_info
  end

  keyrelease do |k|
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
    @info.replace "#{@pressed_keys.inspect} are PRESSED."
  end

  def drone
    @ardrone.drone
  end
end

actors = [
  ArDrone.new
]

Artoo::Robot.work!(actors)
