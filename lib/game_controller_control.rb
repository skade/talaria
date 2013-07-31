module GameControllerControl
  SONY_VENDOR_ID = 1356
  CONTROLLER_PRODUCT_ID = 616

  def start_game_controller!
    begin
      require './hidapi-1.1.jar'
    rescue LoadError
      warn("put hidapi-1.1.jar in your classpath to use a game controller")
      return
    end

    com.codeminders.hidapi.ClassPathLibraryLoader.loadNativeHIDLibrary
    import com.codeminders.hidapi.HIDManager

    at_exit do
      HIDManager.instance.release
    end

    begin
      device = HIDManager.instance.openById(SONY_VENDOR_ID, CONTROLLER_PRODUCT_ID, nil)
    rescue com.codeminders.hidapi.HIDDeviceNotFoundException => e
      warn("could not find connected controller")
      return
    end

    @game_controller = GameController.new(drone, device)
    Thread.new { @game_controller.run! }
  end
end