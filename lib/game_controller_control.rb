module GameControllerControl
  def start_game_controller!
    begin
      device = Javahidapi.manager.openById(Javahidapi::VendorIDs::SONY, Javahidapi::ProductIDs::PS3_CONTROLLER, nil)
    rescue com.codeminders.hidapi.HIDDeviceNotFoundException
      warn("could not find connected controller")
      return
    end

    @game_controller = GameController.new(drone, device)
    Thread.new { @game_controller.run! }
  end
end