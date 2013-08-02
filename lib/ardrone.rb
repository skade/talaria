require 'javahidapi'

class ArDrone < Artoo::Robot
  attr_accessor :listener

  connection :ardrone, :adaptor => :ardrone, :port => '192.168.1.1:5556'
  device :drone, :driver => :ardrone, :connection => :ardrone

  connection :navigation, :adaptor => :ardrone_navigation, :port => '192.168.1.1:5554'
  device :nav, :driver => :ardrone_navigation, :connection => :navigation

  connection :hid, :adaptor => :hid, :port => "#{Javahidapi::VendorIDs::SONY}:#{Javahidapi::ProductIDs::PS3_CONTROLLER
  }"
  device :controller, :driver => :ps3_controller, :connection => :hid, :interval => 0.05

  work do
    on nav, :update => :nav_update
    on controller, :right_joystick => ->(event, values) {
      if values[:x] < 0
        drone.turn_left(values[:x] / -128.0)
      else
        drone.turn_right(values[:x] / 128.0)
      end

      if values[:y] < 0
        drone.down(values[:y] / -128.0)
      else
        drone.up(values[:y] / 128.0)
      end
    }

    on controller, :left_joystick => ->(event, values) {
      if values[:x] < 0
        drone.left(values[:x] / -128.0)
      else
        drone.right(values[:x] / 128.0)
      end

      if values[:y] < 0
        drone.backward(values[:y] / -128.0)
      else
        drone.forward(values[:y] / 128.0)
      end
    }

    on controller, :l1 => ->(event, down, pressed) {
      drone.front_camera if pressed
    }
    on controller, :r1 => ->(event, down, pressed) {
      drone.bottom_camera if pressed
    }
    on controller, :l2 => ->(event, down, pressed) {
      drone.take_off if pressed
    }
    on controller, :r2 => ->(event, down, pressed) {
      drone.land if pressed
    }
    on controller, :cross => ->(event, down, pressed) {
      drone.emergency if pressed
    }

    drone.start
  end

  def nav_update(*data)
    listener.nav_update(*data) if listener.respond_to? :nav_update
  end
end
