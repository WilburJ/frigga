$: << "./"
require 'sinatra/base'

require 'rack/rpc'
require 'frigga/rpc'
require 'frigga/talk'

#LOG!!!!!!!!!

module Frigga

  class WebServer < Sinatra::Base
    configure do
      set :public_folder, Proc.new { File.join(File.expand_path(""), "static") }
      set :views, Proc.new { File.join(File.expand_path(""), "views") }
      enable :sessions
      set :port => HTTP_PORT
      set :bind => '0.0.0.0'
      set :show_exceptions => false
    end
    
    before '*' do
      if request.ip == '127.0.0.1'
        puts "match ip"
      else

        use Rack::Auth::Basic, "Protected Area" do |username, password|
          username == 'foo' && password == 'bar'
        end
      end
      #puts request.path_info
      #puts request.ip
      #puts GOD_SOCK
      @ver = VER
    end

    not_found do
      erb :notfound
    end

    error do
      @error = env['sinatra.error'].message
      erb :error
    end

    get '/' do
      if session[:notice]
        @msg = session[:notice].dup
        session[:notice] = nil
      end
      puts "do it"
      hi = Frigga::Talk_to.god('status')
      puts hi
      @process = []
      
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
          @process << [k, status, start_time, v[:start], pid]
        end
      end
      erb :index
    end

    get '/log' do
      @log = `tail -n 200 #{DIR}/log/god.log`
      unless $? == 0
        raise "tail -n 200 #{DIR}/log/god.log failed!"
      end
      @where_is_log = "#{DIR}/log/god.log"
      erb :log
    end

    post '/god/:action' do |action|
      unless %w(restart start stop).include?(action)
        raise "Don't know action[#{action}]"
      end
      hi = Frigga::Talk_to.god(action, params[:name])
      puts "hi: #{hi}"
      if hi.empty?
        raise "#{action.capitalize} #{params[:name]} failed! #{hi[1]}"
      end
      session[:notice] = "Action: #{action} process[#{params[:name]}] success!"
      sleep 0.5
      redirect to '/'
    end

    use Rack::RPC::Endpoint, Frigga::RPC::Server.new
  end
end

