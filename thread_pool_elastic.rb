require 'thread_pool_base'

module CustomThreadPool
  class Elastic < Base

    attr_reader :elastic_pool

    def initialize(config)
      super
      @elastic_pool = Array.new
      @elastic_max = config[:emax] || 4
      @elastic_state = true
      @elastic_start_condi = config[:econdi] || 200
      #@observe_thread = observe_thread
    end


    #观察者线程
    #监控线程池中的线程是否有死掉的
    #如果有，则调用清理函数，创建新的线程
    def observe_thread
      Thread.new do
        while @while_state
          sleep(@observe_wakeup)
          result = select_dead_thread(@thread_pool)
          elastic_manager_run if @queue.size >= @elastic_start_condi
          if @elastic_pool.size > 0
            dead_elastic = select_dead_thread(@elastic_pool)
            clear_elastic_dead_thread(dead_elastic) unless dead_elastic.size > 0
          end
          next if result.size <= 0
          clear_dead_thread(result)
        end
      end
    end

    private

    def clear_elastic_dead_thread(arr)
      arr.each do |val|
        @mutex.synchronize{
          @elastic_pool.delete(val)
        }
      end
    end

    def death(thread)
      @mutex.synchronize do
        @elastic_pool.delete(thread)
      end
      thread.kill
    end

    #管理
    def elastic_manager_run
      @mutex.synchronize do
        return false if @elastic_pool.size >= @elastic_max
        @elastic_pool << generate_elastic_thread
      end
    end


    #生成弹性线程
    #如果任务列队为空时，自动销毁自己
    def generate_elastic_thread
      thread = Thread.new do
        while @elastic_state
          begin
            runble = get_task
            if runble
              runble.task.call
            else
              death(Thread.current)
            end
          rescue => error
            raise error if runble.is_error?
            runble.error_occur(error.message)
            return_task(runble)
          end
        end
      end
      return thread
    end


  end
end