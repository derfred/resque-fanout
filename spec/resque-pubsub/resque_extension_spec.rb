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

  describe "unsubscribe" do

    it "should raise ArgumentError if neither class nor queue is specified" do
      lambda do
        Resque.unsubscribe :new_user
      end.should raise_error(ArgumentError)
    end

    it "should ignore request for non existant mapping" do
      lambda do
        Resque.unsubscribe :new_user, :queue => :account
      end.should_not raise_error
    end

    describe "subscription by class" do

      before :each do
        Resque.subscribe :new_user, :class => BillingListener
      end

      it "should remove mapping if class is given" do
        Resque.unsubscribe :new_user, :class => BillingListener
        Resque.queues_for(:new_user).should == nil
      end

      it "should remove mapping if queue is given" do
        Resque.unsubscribe :new_user, :queue => :billing
        Resque.queues_for(:new_user).should == nil
      end

    end

    describe "subscription by queue" do

      before :each do
        Resque.subscribe :new_user, :queue => :billing
      end

      it "should remove mapping if class is given" do
        Resque.unsubscribe :new_user, :class => BillingListener
        Resque.queues_for(:new_user).should == nil
      end

      it "should remove mapping if queue is given" do
        Resque.unsubscribe :new_user, :queue => :billing
        Resque.queues_for(:new_user).should == nil
      end

    end

    describe "multiple subscriptions" do
    
      before :each do
        Resque.subscribe :new_user, :queue => :billing
        Resque.subscribe :new_user, :queue => :account
      end

      it "should remove mapping if class is given" do
        Resque.unsubscribe :new_user, :class => BillingListener
        Resque.queues_for(:new_user).should == [{
          :queue => "account"
        }]
      end

    end

  end

end
