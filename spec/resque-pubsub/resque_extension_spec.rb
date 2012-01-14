require 'spec_helper'

describe "Resque internals" do

  describe "subscribe" do

    it "should add route if class is specified" do
      Resque.subscribe :new_user, :class => BillingListener

      queues = Resque.queues_for(:new_user)

      queues.size.should == 1
      queues.first[:queue].should == "billing"
      queues.first[:class].should == "BillingListener"
    end

    it "should add route if queue is specified" do
      Resque.subscribe :new_user, :queue => :billing

      queues = Resque.queues_for(:new_user)

      queues.size.should == 1
      queues.first[:queue].should == "billing"
      queues.first[:class].should == nil
    end

    it "should raise ArgumentError if neither class nor queue is specified" do
      lambda do
        Resque.subscribe :new_user
      end.should raise_error(ArgumentError)
    end

  end

end
