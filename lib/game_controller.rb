require 'artoo/drivers/driver'

module Artoo
  module Drivers
    # Wii-based controller shared driver behaviors for Firmata
    class Wiidriver < Driver
      # buttons with pictures
      attr_accessor :square
      attr_accessor :cross
      attr_accessor :circle
      attr_accessor :triangle

      # Front-side buttons
      attr_accessor :l1
      attr_accessor :r1
      attr_accessor :l2
      attr_accessor :r2

      # square small ["select" button
      attr_accessor :select

      # triangular small "start" button
      attr_accessor :start

      # Pressing on joysticks (button)
      attr_accessor :left_joystick_press
      attr_accessor :right_joystick_press

      # PS3 button (sometimes labeled as Home on 3rd party models)
      attr_accessor :ps

      # Direction pad (hatswitch)
      attr_accessor     :hat_switch_left_right
      attr_accessor     :hat_switch_up_down

      # Analog joysticks

      attr_accessor     :left_joystick_x
      attr_accessor     :left_joystick_y

      attr_accessor     :right_joystick_x
      attr_accessor     :right_joystick_y

      # Starts drives and required connections
      def start_driver
        begin
          controller_input = Java::byte[49].new

          every(interval) do
            connection.read(controller_input)
            consume_data(controller_input)
            emit_events
          end

          super
        rescue Exception => e
          Logger.error "Error starting ps3 driver!"
          Logger.error e.message
          Logger.error e.backtrace.inspect
        end
      end

      def watch(field, byte, locator)
        values = self.send(field)
        if values == nil
          values = []
          self.send(:"#{field}=", values)
        end
        last_value = values[0]
        current_value = ((byte & locator) > 0)
        just_pressed = (last_value == false && current_value == true)
        values[0] = current_value
        values[1] = just_pressed
      end

      def consume_data(byte_array)
        buttons = byte_array[2]
        watch(:select, buttons, 1)
        watch(:left_joystick_press, buttons, 2)
        watch(:right_joystick_press, buttons, 4)
        watch(:start, buttons, 8)

        buttons = byte_array[3]
        watch(:l2, buttons, 1)
        watch(:r2, buttons, 2)
        watch(:l1, buttons, 4)
        watch(:r1, buttons, 8)
        watch(:triangle, buttons, 16)
        watch(:circle, buttons, 32)
        watch(:cross, buttons, 64)
        watch(:square, buttons, 128)

        buttons = byte_array[4]
        self.ps = ((buttons & 1) > 0)

        self.left_joystick_x = joystick_coord_conf(byte_array[6]);
        self.left_joystick_y = -joystick_coord_conf(byte_array[7]);
        self.right_joystick_x = joystick_coord_conf(byte_array[8]);
        self.right_joystick_y = -joystick_coord_conf(byte_array[9]);
      end

      def joystick_coord_conf(b)
        v = (b < 0) ? (b + 256) : b
        v - 128
      end

      def emit_events
        if right_joystick_x < 0
          drone.turn_left(right_joystick_x / -128.0)
        else
          drone.turn_right(right_joystick_x / 128.0)
        end

        if right_joystick_y < 0
          drone.down(right_joystick_y / -128.0)
        else
          drone.up(right_joystick_y / 128.0)
        end
      end

      def send_commands
        if right_joystick_x < 0
          drone.turn_left(right_joystick_x / -128.0)
        else
          drone.turn_right(right_joystick_x / 128.0)
        end

        if right_joystick_y < 0
          drone.down(right_joystick_y / -128.0)
        else
          drone.up(right_joystick_y / 128.0)
        end

        if left_joystick_x < 0
          drone.left(left_joystick_x / -128.0)
        else
          drone.right(left_joystick_x / 128.0)
        end

        if left_joystick_y < 0
          drone.backward(left_joystick_y / -128.0)
        else
          drone.forward(left_joystick_y / 128.0)
        end

        if pressed?(:l2)
          drone.take_off
        end

        if pressed?(:r2)
          drone.land
        end

        if pressed?(:cross)
          drone.emergency
        end

        if pressed?(:l1)
          drone.front_camera
        end

        if pressed?(:r1)
          drone.bottom_camera
        end
      end

      def pressed?(sym)
        self.send(sym)[1]
      end

      def run!
        loop {
          device.read(controller_input)

        }
      end
    end
  end
end