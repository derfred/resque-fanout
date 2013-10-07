require 'spec_helper'

describe "Job internals", "self.create" do

  describe "in inline mode" do
    around(:each) do |example|
      _inline = Resque.inline
      Resque.inline = true
      example.run
      Resque.inline = _inline
    end

    it "calls the worker class" do
      NewUserListener.should_receive(:perform).with("name" => "feynman", "account_type" => "qed")
      Resque::Job.create :new_user, NewUserListener, :name => "feynman", :account_type => "qed"
    end
  end

  describe "without subscriptions" do

    it "should enqueue job" do
      Resque::Job.create :new_user, NewUserListener, :name => "feynman", :account_type => "qed"

      job = Resque.reserve(:new_user)
      job.payload_class.should == NewUserListener
      job.args.should == [{ "name" => "feynman", "account_type" => "qed" }]
    end

  end

  describe "with subscriptions" do

    before :each do
      Resque.subscribe :new_user, :class => BillingListener
      Resque.subscribe :new_user, :class => AccountListener
    end

    it "should enqueue jobs" do
      Resque::Job.create :new_user, NewUserListener, :name => "feynman", :account_type => "qed"

      Resque.size(:billing).should == 1
      Resque.size(:account).should == 1
    end

  end

end
