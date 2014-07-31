require "rails_helper"

RSpec.describe Notifier, :type => :mailer do

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  it "should send an e-mail" do
    #@submission = FactoryGirl.create(:submission)
    expect(ActionMailer::Base.deliveries.count).to equal(0)
  end

end
