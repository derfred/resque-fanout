Gem::Specification.new do |s|
  s.name              = "resque-pubsub"
  s.version           = "0.5"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Resque Plugin for pubsub routing between queues"
  s.homepage          = "http://github.com/derfred/resque-pubsub"
  s.email             = "ich@derfred.com"
  s.authors           = [ "Frederik Fix" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.description       = <<desc
A Resque plugin that provides endpoints which distributes Jobs submitted to them to (multiple) subscribing queues. Useful for loosely coupled inter-application communication.
desc
end
