$:.unshift(File.expand_path(__dir__))
require 'thread_pool_elastic'

module CustomThreadPool

  def thread_pool(config={})
    CustomThreadPool::Elastic.send(:new,config)
  end
end
#引入至object对象
#可以全局使用
extend CustomThreadPool

