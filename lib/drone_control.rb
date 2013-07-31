module DroneControl
  def start_drone!
    @ardrone = ArDrone.new()
    Thread.new { Artoo::Robot.work!([@ardrone]) }
  end

  def drone
    @ardrone.drone
  end
end