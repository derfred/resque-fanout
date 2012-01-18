require 'rspec'
$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))
require 'resque-fanout'

RSpec.configure do |config|
  config.before :each do
    Resque.redis.flushall
  end
end

#
# Test Workers
#

class BillingListener

  @queue = :billing

  def self.perform(user_hash)
    raise "failure" if user_hash[:name] == "failure"
  end

end

class AccountListener

  @queue = :account

  def self.perform(user_hash)
    
  end

end

class NewUserListener

  @queue = :new_user

  def self.perform(user_hash)
    
  end

end
