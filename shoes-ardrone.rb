require 'shoes/swt'

Dir.chdir(File.dirname(__FILE__))
$LOAD_PATH << File.dirname(__FILE__) + "/lib"

require 'bundler'
Bundler.require

require 'ardrone'
require 'drone_control'
require 'video_stream'
require 'keyboard_control'
require 'indoor_control'

class Shoes::App
  include DroneControl
  include VideoStream
  include KeyboardControl
  include IndoorControl
end

Shoes.app do
  start_drone!
  start_video_stream!
  setup_keyboard_control!
  setup_indoor_control!

  @image = image @current_image

  animate(8) do
    @image.path = @current_image
  end
end