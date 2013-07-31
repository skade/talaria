module KeyboardControl
  def setup_keyboard_control!
    @key_bindings = {}
    @key_states = {}
    @pressed_keys = Set.new

    keypress do |k|
      handle_keypress k

      @pressed_keys << k
    end

    keyrelease do |k|
      handle_keyup k

      @pressed_keys.delete k
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
end