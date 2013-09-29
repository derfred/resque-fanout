$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../lib'))

require 'resque'
require 'resque/server'

require 'resque-fanout/resque_extension'
require 'resque-fanout/job_extension'
require 'resque-fanout/fanout_server'
