module Frigga
  require "drb"
  require 'singleton'
  class Talk
    include Singleton
    def initialize
      @server = DRbObject.new(nil, "drbunix://#{GOD_SOCK}")
      ping
    end

    def ping
      begin 
        @server.ping
      rescue DRb::DRbConnError
        raise "God server is not available, #{GOD_SOCK}"
      end
    end 

    def god(command, task = "")
      if %w{status}.include?(command)
        ping
        statuses = @server.status
      elsif %w{start stop restart monitor unmonitor remove}.include?(command)
        ping
        watches = @server.control(task, command)
      else
        raise "Command '#{command}' is not valid."
      end
    end
  end #talk
  Talk_to = Frigga::Talk.instance

end
