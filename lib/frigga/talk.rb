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
        status
      elsif %w{start stop restart monitor unmonitor remove}.include?(command)
        ping
        watches = @server.control(task, command)
      else
        raise "Command '#{command}' is not valid."
      end
    end

    def status
      hi = @server.status
      process = []
      unless hi.nil? || hi.empty?
        hi.each do |k, v|
          next if k =~ /Frigga/i
          start_time = ""
          status = v[:state] == :up ? 'running' : (v[:state] == :unmonitored ? 'stop' : 'something wrong!')
          pid = v.fetch :pid, nil
          if v[:state] == :up
            if ! pid.nil? && File.exist?("/proc/#{pid}")
              jiffies =  IO.read("/proc//#{pid}/stat").split(/\s/)[21].to_i
              uptime = IO.readlines("/proc/stat").find {|t| t =~ /^btime/ }.split(/\s/)[1].strip.to_i
              start_time = Time.at(uptime + jiffies / 100).strftime("%Y-%m-%d %H:%M:%S")
            else
              status = 'flapping'
              start_time = "Can't find pid:#{pid}"
            end
              
          end
          process << [k, status, start_time, v[:start], pid]
        end
      end
      process
    end
  end #talk
  Talk_to = Frigga::Talk.instance

end
