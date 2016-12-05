require 'thread_error'
require 'task/base'


module CustomThreadPool

  class Base

    attr_reader :thread_pool,:queue

    def initialize(config)
      @thread_pool = Array.new #线程池
      @queue = Array.new #列队
      @init_thread = config[:init] || 8 #起始线程
      #@max_thread = config[:max_thread] || 16 #最大线程数
      @max_queue = config[:max_queue] || 1024 #最大列队数
      @mutex = Mutex.new
      @thread_wakeup_time = config[:await]|| 2#线程挂起时间
      @while_state = true
      @observe_wakeup = 10
      @observe_thread = observe_thread
      #生成线程池
      thread_spawn
    end

    def set_task(&blk)
      task = TaskObject.new(blk)
      #raise PoolError::ParamsNotProcError unless blk.is_a?(Proc)
      raise PoolError::QueueFullError if @queue.size >= @max_queue
      @mutex.synchronize do
        @queue.push(task)
      end
    end

    private

    #清除死亡线程
    def select_dead_thread(arr)
      arr.select do |val|
        !(val.alive?)
      end
    end

    #观察者线程
    #监控线程池中的线程是否有死掉的
    #如果有，则调用清理函数，创建新的线程
    def observe_thread
      Thread.new do
        while @while_state
          sleep(@observe_wakeup)
          result = select_dead_thread(@thread_pool)
          # result = @thread_pool.select do |val|
          #   !(val.alive?)
          # end
          next if result.size <= 0
          clear_dead_thread(result)
        end
      end
    end

    #清除死掉的线程
    #接收一个数组
    #数组中表示要删除的线程
    #注意数组参数不能为空数组或nil值
    #会自动替换死掉的线程
    def clear_dead_thread(arr)
      arr.each do |val|
        @mutex.synchronize{
          @thread_pool.delete(val)
          @thread_pool << thread_task_generate
        }
      end
    end

    #获取任务
    def get_task
      @mutex.synchronize{
        #return false if @queue.size <= 0
        return @queue.shift || false
      }
    end

    def return_task(task)
      @mutex.synchronize do
        @queue.unshift(task)
      end
    end

    def thread_task_generate
      return Thread.new do
        while @while_state
          begin
            runble = get_task
            if runble
              runble.task.call
            else
              sleep(@thread_wakeup_time)
            end
          rescue => error
            raise error if runble.is_error?
            runble.error_occur(error)
            return_task(runble)
          end
        end
      end
    end



    def thread_spawn
      @init_thread.times do
        @mutex.synchronize do
          @thread_pool << thread_task_generate
        end
      end
    end

  end
end