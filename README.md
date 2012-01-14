Resque Plugin for pubsub routing between queues
===============================================

This plugin allows you to define "exchanges" which look like regular Resque queues, but rather than processing jobs they distribute them to one or more other queues. The mapping between exchanges and queues can change at runtime. A code based configuration method as well as a web frontend are provided.

This is useful for loosely coupled asynchronous communication between multiple applications.


Consider a system consisting of three applications. The main frontend application, an internal one processing billing and another handling user accounts. When a new user registers work needs to be performed in the last two.


In the billing application define the following worker:

``` ruby
class BillingListener

  @queue = :payroll

  def self.perform(user_hash)
    
  end

end

Resque.subscribe :new_user, :class => BillingListener
```

In the user accounts application define this worker:

``` ruby
class AccountListener

  @queue = :accounts

  def self.perform(user_hash)
    
  end

end

Resque.subscribe :new_user, :class => AccountListener
```

When a new user registers in the frontend application execute:

``` ruby
Resque.publish :new_user, :user_name => :feynman, :account_type => :qed
```

The job will then be processed by both the BillingListener and the AccountListener in the context of the respective applications.


PubSub semantics
================

The mapping between exchange and queues is maintained in the Redis server and can therefore change at runtime. The job distribution is performed upon job submission. Exchanges override queues with the same name.

The mapping is written to Redis by the following call:

``` ruby
Resque.subscribe :new_user, :class => AccountListener
```

This call will do two things

1. Add the queue defined for AccountListener to the outbound list for the exchange "new_user"
2. Set the class AccountListener as the class handling the request on the queue defined in step 1

The second step is necessary because the class handling the jobs sent to the exchange "new_user" might be different in the respective receiving applications. The receiving class is set by setting the "class" attribute in the Job definition when it is pushed to the queue.

The above semantics allow you to reroute an existing queue. Consider the above example but the frontend application also defines the following worker:

``` ruby
class NewUserListener

  @queue = :new_user

  def self.perform(user_hash)
    
  end

end

Resque.subscribe :new_user, :class => NewUserListener
```

If you then do the following in the frontend application,

``` ruby
Resque.enqueue(NewUserListener, :user_name => :feynman, :account_type => :qed)
```

the job will be performed by all three workers in their respective application contexts.


The `Resque.subscribe` method provides another mode which does not set the handling class:

``` ruby
Resque.subscribe :new_user, :queue => :accounts
```

This will of course only work if the receiving applications have a worker called `NewUserListener`. Using `Resque.publish` with this exchange will cause an exception.


Managing the Exchange -> Queue mapping
======================================

The mapping can be defined either by the `Resque.subscribe` method or through the web frontend. A relevant mapping is created by the `Resque.subscribe` call. Therefore if you delete a mapping in the web frontend but rerun `Resque.subscribe` it will reappear. Depending on your circumstances this may or may not be what you expect. It is recommended to place your mapping definitions in a Rake task similar to  `rake db:migrate`


