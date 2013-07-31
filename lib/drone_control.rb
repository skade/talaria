module DroneControl
  def start_drone!
    @ardrone = ArDrone.new
    @ardrone.listener = self
    @nav_para = para ""
    Thread.new { Artoo::Robot.work!([@ardrone]) }
  end

  def drone
    @ardrone.drone
  end

  def nav_update(*data)
    text = ""
    state = data[1]
    text << "flying? #{state.flying?}\n"
    text << "video_enabled? #{state.video_enabled?}\n"
    text << "vision_enabled? #{state.vision_enabled?}\n"
    text << "low_battery? #{state.low_battery?}\n"
    puts text
    @nav_para.replace text
  end
end