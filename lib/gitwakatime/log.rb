module GitWakaTime
  class Log
    def initialize(msg, color = nil)
      @color = color
      @msg = msg
      print_message
    end

    def print_message
      if @color.nil?
        puts @msg
      else
        puts @msg.send(@color)
      end
    end
  end
end
