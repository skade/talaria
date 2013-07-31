module VideoStream
  def stream
    unless @pid && Process.waitpid(@pid, Process::WNOHANG)
      @ffmpeg = nil
      @pid = nil
      @current_image = @connecting
    end

    @ffmpeg ||= IO.popen(["ffmpeg",
                       "-i",
                       "tcp://192.168.1.1:5555",
                       "-f",
                       "image2pipe",
                       "-vcodec",
                       "png",
                       "-r",
                       "8",
                       "-"],
                       :external_encoding => "binary")
    @pid = @ffmpeg.pid
    @ffmpeg
  end

  def start_video_stream!
    @connecting = File.read("Connecting.png", mode: "rb")

    @current_image = @connecting
    @partial_image = ""

    Thread.new do
      loop do
        begin
          input = stream.read(100000)
          images = input.split(/(?=\x89PNG)/n)

          if images.length == 1
            #puts "found fragment"
            upcoming_image_fragment = images.first
            @partial_image << upcoming_image_fragment
          elsif images.length == 2
            #puts "completed image"

            end_of_upcoming_image, upcoming_image_fragment = images
            @partial_image << end_of_upcoming_image

            @current_image = @partial_image

            @partial_image = upcoming_image_fragment
          elsif images.length > 2
            #puts "found full image"

            full_image, upcoming_image_fragment = images[-2..-1]
            @current_image = full_image

            @partial_image = upcoming_image_fragment
          end
          File.open("debug.png", "wb") do |f|
            f.write @current_image
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  end
end