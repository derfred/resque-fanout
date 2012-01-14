module ResqueExtension

  def self.apply
    Resque.extend ResqueExtension
  end


  def subscribe(exchange, options={})
    raise ArgumentError, "either class or queue param must be supplier" unless options[:queue] || options[:class]

    queue = options[:queue] || queue_from_class(options[:class])
    redis.sadd("exchanges:#{exchange.to_s}", queue.to_s)
    redis.hset("exchanges:class:#{exchange.to_s}", queue.to_s, options[:class].to_s) if options[:class]
    redis.sadd(:exchanges, exchange.to_s)
  end

  def unsubscribe(exchange, options={})
    raise ArgumentError, "either class or queue param must be supplier" unless options[:queue] || options[:class]

    queue = options[:queue] || queue_from_class(options[:class])
    redis.srem("exchanges:#{exchange.to_s}", queue.to_s)
    redis.hdel("exchanges:class:#{exchange.to_s}", queue.to_s)
    if redis.scard("exchanges:#{exchange.to_s}") == 0
      redis.srem(:exchanges, exchange.to_s)
    end
  end

  def queues_for(exchange)
    if redis.sismember(:exchanges, exchange.to_s)
      klasses = Hash[redis.hgetall("exchanges:class:#{exchange.to_s}")]
      redis.smembers("exchanges:#{exchange.to_s}").map do |queue|
        res = { :queue => queue }
        res[:class] = klasses[queue] if klasses[queue]
        res
      end
    end
  end


  def publish(exchange, *args)
    
  end

end

ResqueExtension.apply
