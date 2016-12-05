# ruby_thread_pool


看到java线程池很有趣，自己随手用ruby写了个线程池


线程池分为2种模式

Base：基础模式，生成若干个线程，队列对中的任务进行处理。

Elastic：弹性模式，生成若干个线程后，若列队中任务过多，则会产生一个弹性线程，来分担处理任务列队中的任务，在任务列表为空后，弹性线程会自动销毁自己。

#使用方法
require './thread_pool'

即可进行使用，默认使用弹性模式，默认任务列队大于200后，会开始生成弹性线程，弹性线程个数默认最大值为4个，多余4个后则不会再产生弹性线程

//可以自行配置参数

//例如 thread_pool(:max_queue=>200)

//任务设定,默认插入到main Object中

    POOL = thread_pool
    
    300.times do
    
        POOL.set_task do
        
          #这里会生成一个Proc 对象，存放到任务列队，等待线程执行
          
          sleep(2)
          
          puts 'here task is running'
          
        end
        
    end
    
    puts 'while ending'

//或者直接引入
    
    
    require 'thread_pool_elastic' #引入弹性线程
    
    thread_pool = CustomThreadPool::Elastic.new(:max_queue=>200)
    
