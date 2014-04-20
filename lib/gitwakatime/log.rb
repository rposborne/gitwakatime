module GitWakaTime
  class Log
    def initialize(msg)
      print_message(msg)
    end

    def print_message(msg , color = nil)
      if color.nil?
        ap msg
      else
        puts msg.send(color)
      end
    end
  end
end
