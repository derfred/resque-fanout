$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'resque'
require 'resque/server'

require 'resque-pubsub/resque_extension'
require 'resque-pubsub/job_extension'
