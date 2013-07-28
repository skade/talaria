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
    drone.take_off if k == :up
    drone.land if k == :down
    drone.turn_left 0.1 if k == :left
    drone.turn_right 0.1 if k == :right

    @pressed_keys << k
    update_info
  end

  keyrelease do |k|
    drone.turn_left 0 if k == :left
    drone.turn_right 0 if k == :right

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
