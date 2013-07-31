class ArDrone < Artoo::Robot
  attr_accessor :listener

  connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
  device :drone, :driver => :ardrone, :connection => :ardrone

  connection :navigation, :adaptor => :ardrone_navigation, :port => '192.168.1.1:5554'
  device :nav, :driver => :ardrone_navigation, :connection => :navigation

  work do
    on nav, :update => :nav_update

    drone.start
  end

  def nav_update(*data)
    listener.nav_update(*data) if listener.respond_to? :nav_update
  end
end
