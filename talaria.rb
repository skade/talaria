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
require 'game_controller'
require 'game_controller_control'

class Shoes::App
  include DroneControl
  include VideoStream
  include KeyboardControl
  include IndoorControl
  include GameControllerControl
end

Shoes.app :width => 1024, :height => 700 do
  start_drone!
  start_video_stream!
  setup_keyboard_control!
  setup_indoor_control!
  start_game_controller!
end