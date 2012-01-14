class Resque::Job

  def self.create(queue, klass, *args)
    Resque.validate(klass, queue)

    if Resque.inline?
      constantize(klass).perform(*decode(encode(args)))
    elsif queues = Resque.queues_for(queue)
      queues.each do |_queue|
        Resque.push(_queue[:queue], :class => (_queue[:class] || klass.to_s), :args => args)
      end
    else
      Resque.push(queue, :class => klass.to_s, :args => args)
    end
  end

end
