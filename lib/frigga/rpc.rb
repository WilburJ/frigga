module Frigga
  module RPC
    require 'rack/rpc'
    require 'sinatra/base'
    Dir.glob(File.join(File.dirname(__FILE__), 'rpc', "*.rb")) do |file|
      require file
    end
    class Server < Rack::RPC::Server

      #include rpc/*.rb and regsiter rpc call
      #eg. rpc/god.rb   god.hello
      @@rpc_list = []
      Dir.glob(File.join(File.dirname(__FILE__), 'rpc', "*.rb")) do |file|
        rpc_class = File.basename(file).split('.rb')[0].capitalize
        rpc_list = []
        eval "include Frigga::RPC::#{rpc_class}"
        eval "rpc_list = Frigga::RPC::#{rpc_class}::RPC_LIST"
        rpc_list.each do |rpc_name|
          rpc "#{rpc_class.downcase}.#{rpc_name}" => rpc_name.to_sym
          @@rpc_list << "#{rpc_class.downcase}.#{rpc_name}"
        end
      end
      
      def help
        rpc_methods = (['help'] + @@rpc_list.sort).join("\n")
      end
      rpc "help" => :help

      before_filter :check_auth

      def check_auth
        puts DIR

        puts "wo kao"
        puts request.ip
      end 

    end
  end #RPC
end
