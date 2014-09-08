require 'rails_helper'
require 'spec_helper'

RSpec.describe Notifier, type: :mailer do

  before(:each) do
    @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context "when a submission is created" do

    before do
      # Create admins, whom we send the "new proposal" e-mail to.
      @admins = []
      (@num = rand(1..10)).times { @admins << FactoryGirl.create(:admin) }

      @advisor = FactoryGirl.create(:advisor)
      @project = FactoryGirl.create(:project, advisor: @advisor)
    end

    it "should send an e-mail" do
      # When a student applies, we send an e-mail only to the advisor.
      expect{ FactoryGirl.create(:submission, project: @project) }.
        to change{ ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should send an e-mail with the appropriate subject" do
      FactoryGirl.create(:submission, project: @project)
      expect(ActionMailer::Base.deliveries.last.subject).to \
        include "New application"
    end

    it "should send an e-mail to the advisor and admins" do
      expect(ActionMailer::Base.deliveries.count).to eq(@num)

      # According to submission.rb, we first send an e-mail to the advisor
      # who created the project.
      FactoryGirl.create(:submission, project: @project)
      expect(ActionMailer::Base.deliveries.last.to).to \
        include @project.advisor_email

      # We then send an e-mail to each admin.
      (1..@num).each do |n|
        expect(ActionMailer::Base.deliveries[n]).to \
          include @admins[n-1].email
      end
    end
  end

  context "when a project is proposed" do

    before { (@num = rand(1..10)).times { FactoryGirl.create(:admin) } }

    it "should send an e-mail" do
      # We expect the number of deliveries to equal the number of admins we
      # made in the `before` block.
      @project = FactoryGirl.create(:project)
      expect(ActionMailer::Base.deliveries.count).to equal(@num)
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
    end
  end

  context "when an evaluation is created" do
    before do
      # Create admins, whom we send the "new proposal" e-mail to.
      (@num = rand(1..10)).times { FactoryGirl.create(:admin) }
      @advisor = FactoryGirl.create(:advisor)
      @project = FactoryGirl.create(:project)
      @submission = FactoryGirl.create(:submission, project: @project)
      @submission.status = "accepted"
      @submission.status_approved = true
      @submission.status_published = true
    end
    it "should send an e-mail" do
      expect{ FactoryGirl.create(:evaluation, submission: @submission,
                                 advisor_id: @advisor.id) }.to \
        change{ ActionMailer::Base.deliveries.count }.by(@num)
    end
  end

end
