require 'spec_helper'

describe "Resque extensions and behaviour changes" do

  describe "publish" do

    def publish
      Resque.publish :new_user, :name => "feynman", :account_type => "qed"
    end

    describe "with single subscriber by class" do

      before :each do
        Resque.subscribe :new_user, :class => BillingListener
      end

      it "should append job to queue" do
        publish
        Resque.size(:billing).should == 1
      end

      it "should append buildable job to queue" do
        publish
        job = Resque.reserve(:billing)
        job.payload_class.should == BillingListener
        job.args.should == [{ "name" => "feynman", "account_type" => "qed" }]
      end

    end

    describe "with single subscriber by queue name" do

      before :each do
        Resque.subscribe :new_user, :queue => :billing
      end

      xit "should raise exception" do
        # not sure yet whether to raise error on sender or receiver side
      end

    end

    describe "multiple subscribers" do

      before :each do
        Resque.subscribe :new_user, :class => BillingListener
        Resque.subscribe :new_user, :class => AccountListener
      end

      it "should distribute jobs to multiple queues" do
        publish
        Resque.size(:billing).should == 1
        Resque.size(:account).should == 1
      end

      it "should set specific class on each queue" do
        publish
        Resque.reserve(:billing).payload_class.should == BillingListener
        Resque.reserve(:account).payload_class.should == AccountListener
      end

    end

    it "should unsubscribe" do
      Resque.subscribe :new_user, :class => AccountListener
      Resque.unsubscribe :new_user, :class => BillingListener

      Resque.publish :new_user, :name => "feynman", :account_type => "qed"

      Resque.size(:billing).should == 0
      Resque.size(:account).should == 1
    end

  end

  describe "enqueue" do

    def enqueue
      Resque.enqueue NewUserListener, "name" => "feynman", "account_type" => "qed"
    end

    describe "subscriber by class" do

      before :each do
        Resque.subscribe :new_user, :class => NewUserListener
      end

      it "should append job to queue" do
        enqueue
        job = Resque.reserve(:new_user)
        job.payload_class.should == NewUserListener
        job.args.should == [{ "name" => "feynman", "account_type" => "qed" }]
      end

    end

    describe "subscriber by queue" do

      before :each do
        Resque.subscribe :new_user, :queue => :new_user
      end

      it "should append job to queue" do
        enqueue
        job = Resque.reserve(:new_user)
        job.payload_class.should == NewUserListener
        job.args.should == [{ "name" => "feynman", "account_type" => "qed" }]
      end

    end

    describe "exchange shadowing queue" do

      before :each do
        Resque.subscribe :new_user, :class => BillingListener
      end

      it "should distribute job to subscribed queue" do
        enqueue
        job = Resque.reserve(:billing)
        job.payload_class.should == BillingListener
        job.args.should == [{ "name" => "feynman", "account_type" => "qed" }]
      end

      it "should not deliver to shadowed queued" do
        enqueue
        Resque.size(:new_user).should == 0
      end

    end

  end

  describe "unsubscribe" do

    def publish
      Resque.publish :new_user, :name => "feynman", :account_type => "qed"
    end

    describe "from subscriber by class" do

      before :each do
        Resque.subscribe :new_user, :class => BillingListener
        Resque.subscribe :new_user, :class => AccountListener
      end

      it "should not distribute to unsubscribed queues" do
        Resque.unsubscribe :new_user, :class => BillingListener
        publish
        Resque.size(:billing).should == 0
      end

    end

    describe "from subscriber by queue" do

      before :each do
        Resque.subscribe :new_user, :queue => :billing
        Resque.subscribe :new_user, :queue => :account
      end

      it "should not distribute to unsubscribed queues" do
        Resque.unsubscribe :new_user, :queue => :billing
        publish
        Resque.size(:billing).should == 0
      end

    end

  end

end
