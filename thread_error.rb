
module CustomThreadPool
  #错误Exception类
  module PoolError
    class QueueFullError < Exception
      def message
        "thread pool was full"
      end
    end

    class ParamsNotProcError < TypeError
      def message
        "params must be a Proc"
      end
    end

  end
end