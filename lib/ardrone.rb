class ArDrone < Artoo::Robot
  connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
  device :drone, :driver => :ardrone, :connection => :ardrone

  work do
    drone.start
  end
end
