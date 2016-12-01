require './thread_pool'


#模拟java 线程池的一个实现
#调用一个线程池
#可以自行配置参数
#例如 thread_pool(:max_queue=>200)
POOL = thread_pool


300.times do
  POOL.set_task do
    sleep(2)
    puts 'hello'
  end
end

puts "while ending"


sleep(120)

