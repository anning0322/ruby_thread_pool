
#任务对象
module CustomThreadPool
  class TaskObject

    attr_accessor :task

    attr_reader :error_message

    def initialize(task)
      @task = check_task(task)
      @error_state = false
      @error_obj = nil
    end

    def call
      @task.call
    end

    def error_occur(obj)
      @error_obj = obj
      @error_state = true
    end

    def is_error?
      @error_state
    end

    private

    def check_task(task)
      raise PoolError::ParamsNotProcError unless task.is_a?(Proc)
      task
    end
  end
end