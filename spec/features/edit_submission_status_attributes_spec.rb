require 'rails_helper'
require 'spec_helper'

describe "Editing a submission's 'status' attributes", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter    = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin      = FactoryGirl.create(:admin)
    @advisor    = FactoryGirl.create(:advisor)
    @student    = FactoryGirl.create(:student)
    @project    = FactoryGirl.create(:project, :accepted_and_published,
                                     :in_current_quarter, advisor: @advisor)
    @submission = FactoryGirl.create(:submission, student: @student,
                                     project: @project, status: "pending",
                                     status_approved: false,
                                     status_published: false)
  end

  # Accept _or_ reject? (Use shared examples?)

  context "accepting or rejecting the submission" do
    before(:each) { ldap_sign_in(@advisor) }

    context "visiting the submission page" do
      before(:each) { visit submission_path(@submission) }

      context "updating the submission's status" do
        before(:each) { click_link "accept" }

        it "should change the submission's status" do
          expect(@submission.reload.status).to eq("accepted")
        end

        context "viewed by the advisor" do

          it "should show the updated status on the submission's page" do
            expect(current_path).to eq(submission_path(@submission))
            expect(page).to have_content("Application accepted.")
            expect(page).to have_selector("div.alert.alert-success")
            within('tr', text: "Status") do
              expect(page).to have_content("Accepted (pending administrator " +
                                           "approval)")
            end
          end

          it "should show the updated status on the 'project's subs' page" do

          end

        end

        context "viewed by the student" do
          before(:each) do
            logout
            ldap_sign_in(@student)
          end

          it "should not be visible on the submission's page" do
            visit submission_path(@submission)
            within('tr', text: "Status") do
              expect(page).to have_content("Pending")
              expect(page).not_to have_content("Accepted")
            end
          end

          it "should not be visible on the student's submission index page " do
            visit users_submissions_path(@student)
            save_and_open_page
            # We should look within the "Status" column, not just the table.
            within("table") do
              expect(page).to have_content("Pending")
              expect(page).not_to have_content("Accepted")
            end
          end
        end
      end
    end
  end

  context "approving or rejecting the advisor's decision" do

    before(:each) { ldap_sign_in(@admin) }

    context "visiting the submission page" do

    end

  end

  context "publishing the submission's status" do

    before(:each) { ldap_sign_in(@admin) }

  end

  # We might want to put this in another spec file.
  context "viewing the submission's status" do

    before(:each) { ldap_sign_in(@student) }

  end

end
