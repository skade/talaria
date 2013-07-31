module IndoorControl
  def setup_indoor_control!
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
  end
end