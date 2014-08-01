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

  context "when a submission is created" do
    it "should send an e-mail" do
      @submission = FactoryGirl.create(:submission)
      expect(ActionMailer::Base.deliveries.count).to equal(1)

      expect{ FactoryGirl.create(:submission) }.to \
        change{ ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context "when a project is proposed" do
    before do
      # Create an admin, whom we send the "new proposal" e-mail to.
      @admin = FactoryGirl.create(:admin)
    end

    it "should send an e-mail" do
      # We expect the number of deliveries to equal the number of admins we
      # made in the `before` block.
      @project = FactoryGirl.create(:project)
      expect(ActionMailer::Base.deliveries.count).to equal(1)
    end
  end

  context "when a submission's status is changed" do
    it "should send an e-mail" do
      @submission = FactoryGirl.create(:submission)
      # We expect the number of deliveries to change by 1, since we deliver
      # once in `#send_respective_update` in submission.rb.
      expect{ @submission.update_attributes(status: "accepted") }.to \
        change{ ActionMailer::Base.deliveries.count }.by(1)

      expect{ @submission.update_attributes(status: "rejected") }.to \
        change{ ActionMailer::Base.deliveries.count }.by(1)

      # What about a change to 'pending'?..
    end
  end

  context "when a project proposal's status is changed" do
    it "should send an e-mail" do
      @project = FactoryGirl.create(:project)
      # We expect the number of deliveries to equal the number of admins we
      # made in the `before` block, plus 1 (for the advisor who proposed
      # the project).
      expect{ @project.update_attributes(status: "accepted") }.to \
        change{ ActionMailer::Base.deliveries.count }.by(1)

      # Vary the number of admins, and test subjects, bodies, etc.
    end
  end

end
