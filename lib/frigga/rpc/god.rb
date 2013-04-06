module Frigga
  module RPC
    module God
      #must have RPC_LIST for regsiter rpc_call
      RPC_LIST = %w(status restart)
      def status
        "#{request.ip}"
        #hi = talk_with_god("status")
        #hi ? hi[1] : "Get status failed! #{hi[1]}"
      end
      def restart(str)
        hi = talk_with_god("restart", str)
        hi ? hi[1] : "Restrat #{str} failed! #{hi[1]}"
      end

      def start(str)
        "Hello, world from RPC Server!  #{arg}"
      end

    end #God
  end
end
