module GitWakaTime
  ##
  # Pretty output, and ability to silence in testing
  class Log
    def initialize(msg, color = nil)
      @color = color
      @msg = msg
      print_message
    end

    def print_message
      return if ENV['waka_log'] == 'false'
      if @color.nil?
        puts @msg
      else
        puts @msg.send(@color)
      end
    end
  end
end
