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

  context "when a user's roles are changed" do
    before do
      @student = FactoryGirl.create(:student)
    end

    it "should send the user an e-mail" do
      expect { @student.update_attributes(advisor: true) }.
        to change{ ActionMailer::Base.deliveries.count }.by(1)
      expect(ActionMailer::Base.deliveries.first.encoded).
        to have_content("You now have privileges for the following roles: " +
                        "advisor and student.")
    end
  end

  # When a submission is submitted, its status becomes "pending".
  context "when a submission is submitted" do

    before do
      # Create admins, whom we send the "new proposal" e-mail to.
      @admins = []
      (@num = rand(1..10)).times { @admins << FactoryGirl.create(:admin) }

      @advisor = FactoryGirl.create(:advisor)
      @student = FactoryGirl.create(:student)
      @project = FactoryGirl.create(:project,
                                    :accepted_and_published,
                                    :in_current_quarter,
                                    advisor: @advisor)
    end

    it "should send an e-mail" do
      # When a student applies, we send an e-mail only to the advisor.
      expect{ FactoryGirl.create(:submission, project: @project,
                                 student: @student,
                                 status: "pending",
                                 status_approved: false,
                                 status_published: false) }.
        to change{ ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should send an e-mail with the appropriate subject" do
      FactoryGirl.create(:submission, project: @project)
      expect(ActionMailer::Base.deliveries.last.subject).
        to include "New application"
    end

    it "should send an e-mail to the advisor" do
      # According to submission.rb, we send an e-mail only to the advisor
      # who created the project.
      FactoryGirl.create(:submission, project: @project)
      # We look at the last e-mail in the array, because the first few were sent
      # to the admins when `@project` was made.
      expect(ActionMailer::Base.deliveries.last.to).
        to include @project.advisor_email
    end

    context "as a draft" do
      it "should not deliver any e-mails" do
        expect{ FactoryGirl.create(:submission, student: @student,
                                   project: @project,
                                   status: "draft",
                                   status_approved: false,
                                   status_published: false) }.
          to change{ ActionMailer::Base.deliveries.count }.by(0)
      end

      context "and then changed from 'draft' to 'pending'" do
        before(:each) do
          @submission = FactoryGirl.create(:submission, student: @student,
                                           project: @project,
                                           status: "draft",
                                           status_approved: false,
                                           status_published: false)
        end
        it "should deliver e-mails" do
          expect{ @submission.update_attributes(status: "pending") }.
            to change{ ActionMailer::Base.deliveries.count }.by(1)
        end
      end
    end
  end

  context "when a project is proposed" do
    before do
      (@num = rand(1..10)).times { FactoryGirl.create(:admin) }
      @advisor = FactoryGirl.create(:advisor)
    end

    context "and immediately submitted" do
      it "should send e-mails to the admins" do
        # We expect the number of deliveries to equal the number of admins we
        # made in the `before` block.
        expect { FactoryGirl.create(:project, :in_current_quarter,
                                    advisor: @advisor) }.
          to change{ ActionMailer::Base.deliveries.count }.by(@num)
      end
    end

    context "as a draft" do
      before(:each) do
        @project = FactoryGirl.create(:project, :in_current_quarter,
                                      status: "draft",
                                      advisor: @advisor)
      end

      it "should not send e-mails to anyone" do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end

      context "and then submitted" do
        it "should send e-mails to the admins" do
          expect { @project.update_attributes(status: "pending") }.
            to change{ ActionMailer::Base.deliveries.count }.by(@num)
        end
      end
    end
  end

  context "when a submission's status is changed" do
    # We make the admins so the e-mails for this example have recipients to
    # be sent to.
    before { (@num = rand(1..10)).times { FactoryGirl.create(:admin) } }

    it "should send an e-mail" do
      @project = FactoryGirl.create(:project, :in_current_quarter,
                                    status: "accepted", status_published: true)
      @submission = FactoryGirl.create(:submission, project: @project)
      # See #send_status_updated in submission.rb. We send e-mails to the
      # admins.
      expect{ @submission.update_attributes(status: "accepted") }.
        to change{ ActionMailer::Base.deliveries.count }.by(@num)

      expect{ @submission.update_attributes(status: "rejected") }.
        to change{ ActionMailer::Base.deliveries.count }.by(@num)
    end
  end

  context "when a project proposal's status is changed" do
    before do
      @admin = FactoryGirl.create(:admin)
      @project = FactoryGirl.create(:project)
      @project.this_user = @admin
    end

    it "should send an e-mail to the admin" do
      # We made one admin.
      expect{ @project.update_attributes(status: "accepted") }.
        to change{ ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  context "when an evaluation is created" do
    before do
      # Create admins, whom we send the "new proposal" e-mail to.
      (@num = rand(1..10)).times { FactoryGirl.create(:admin) }
      @advisor = FactoryGirl.create(:advisor)
      @project = FactoryGirl.create(:project, :in_current_quarter,
                                    advisor: @advisor, status: "accepted",
                                    status_published: true)
      @submission = FactoryGirl.create(:submission, project: @project)
      @submission.status = "accepted"
      @submission.status_approved = true
      @submission.status_published = true
      @template = FactoryGirl.create(:evaluation_template, quarter: @quarter,
                                     start_date: @quarter.start_date,
                                     end_date: @quarter.end_date)
    end

    it "should send an e-mail" do
      # Why does this depend on having the id sequences reset?
      expect{ FactoryGirl.create(:evaluation, submission: @submission,
                                 advisor_id: @advisor.id,
                                 evaluation_template: @template) }.
        to change{ ActionMailer::Base.deliveries.count }.by(@num)
    end
  end
end
