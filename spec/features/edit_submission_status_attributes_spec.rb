require 'rails_helper'
require 'spec_helper'

describe "Editing a submission's 'status' attributes", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter       = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin         = FactoryGirl.create(:admin)
    @advisor       = FactoryGirl.create(:advisor)
    @other_advisor = FactoryGirl.create(:advisor)
    @student       = FactoryGirl.create(:student)
    @other_student = FactoryGirl.create(:student)
    @project       = FactoryGirl.create(:project, :accepted_and_published,
                                        :in_current_quarter, advisor: @advisor)
    @submission    = FactoryGirl.create(:submission, student: @student,
                                        project: @project, status: "pending",
                                        status_approved: false,
                                        status_published: false)
  end

  # Accept _or_ reject? (Use shared examples?)

  # This should be in the new_submission spec file.
  # context "before the advisor or admin has done anything" do
  #   context "as the admin" do

  #   end

  #   context "as the advisor" do

  #   end

  #   context "as the student" do

  #   end
  # end

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

          it "should remove the 'accept' and 'reject' links from its page" do
            expect(page).not_to have_content("You may accept or reject " +
                                             "this application.")
          end

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
            visit project_submissions_path(@project)
            within("table") do
              expect(page).to have_content("Accepted (pending administrator " +
                                           "approval)")
            end
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

          it "should not be visible on the student's submission index page" do
            visit users_submissions_path(@student)
            # We should look within the "Status" column, not just the table.
            within("table") do
              expect(page).to have_content("Pending")
              expect(page).not_to have_content("Accepted")
            end
          end
        end

        context "viewed by an admin" do
          before(:each) do
            logout
            ldap_sign_in(@admin)
          end

          it "should show the status dropdown and checkboxes on its page" do
            visit submission_path(@submission)
            within('tr', text: "Status") do
              expect(page).to have_select("Status", selected: "Accepted")
              expect(page.find("#submission_status_approved")).
                not_to be_checked
              expect(page.find("#submission_status_published")).
                not_to be_checked
            end
          end

          it "should show its status on the 'applications' page" do
            visit submissions_path(@submission)
            within("table") do
              expect(page).to have_content("Accepted (pending administrator " +
                                           "approval)")
              expect(page).not_to have_content("Pending")
            end
          end
        end

        context "viewed by another advisor" do
          before(:each) do
            logout
            ldap_sign_in(@other_advisor)
          end

          it "should redirect when trying to view the sub" do
            visit submission_path(@submission)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when visiting the user's subs pg" do
            visit users_submissions_path(@student)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

        context "viewed by another student" do
          before(:each) do
            logout
            ldap_sign_in(@other_student)
          end

          it "should redirect when trying to view the sub" do
            visit submission_path(@submission)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when visiting the user's subs pg" do
            visit users_submissions_path(@student)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

      end
    end
  end

  context "approving or rejecting the advisor's decision" do

    before(:each) do
      @submission.update_attributes(status: "accepted")
      ldap_sign_in(@admin)
    end

    it "should be initialized with an 'accepted' status" do
      expect(@submission.reload.status).to eq("accepted")
    end

    context "visiting the submission page" do
      before(:each) { visit submission_path(@submission) }

      context "updating the submission's status" do
        before(:each) do
          check "submission_status_approved"
          click_button "Update application status"
        end

        it "should change the submission's 'status_approved' state" do
          expect(@submission.reload.status_approved).to eq(true)
        end

        context "viewed by the advisor" do

          before(:each) do
            logout
            ldap_sign_in(@advisor)
          end

          # It should show "accepted", not "accepted (pending approval)."
          it "should show the updated status on the submission's page" do
            visit submission_path(@submission)
            within('tr', text: "Status") do
              expect(page).to have_content("Accepted")
              expect(page).not_to have_content("Accepted (pending " +
                                               "administrator approval)")
            end
          end

          it "should show the updated status on the 'project's subs' page" do
            visit project_submissions_path(@project)
            within("table") do
              expect(page).to have_content("Accepted")
              expect(page).not_to have_content("Accepted (pending " +
                                               "administrator approval)")
            end
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
              expect(page).not_to have_content("Accepted")
              expect(page).to have_content("Pending")
            end
          end

          it "should not be visible on the student's submission index page" do
            visit users_submissions_path(@student)
            within("table") do
              expect(page).not_to have_content("Accepted")
              expect(page).to have_content("Pending")
            end
          end
        end

        context "viewed by an admin" do
          # We're already signed in as an admin; no need to log out and sign
          # in again.

          it "should show the status dropdown and checkboxes on its page" do
            visit submission_path(@submission)
            within('tr', text: "Status") do
              expect(page).to have_select("Status", selected: "Accepted")
              expect(page.find("#submission_status_approved")).
                to be_checked
              expect(page.find("#submission_status_published")).
                not_to be_checked
            end
          end

          it "should show its status on the 'applications' page" do
            visit submissions_path
            within("table") do
              expect(page).not_to have_content("Accepted (pending " +
                                               "administrator approval)")
              expect(page).to have_content("Accepted")
            end
          end
        end

        context "viewed by another advisor" do
          before(:each) do
            logout
            ldap_sign_in(@other_advisor)
          end

          it "should redirect when trying to view the sub" do
            visit submission_path(@submission)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when visiting the user's subs pg" do
            visit users_submissions_path(@student)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

        context "viewed by another student" do
          before(:each) do
            logout
            ldap_sign_in(@other_student)
          end

          it "should redirect when trying to view the sub" do
            visit submission_path(@submission)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when visiting the user's subs pg" do
            visit users_submissions_path(@student)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

      end
    end

  end

  context "publishing the submission's status" do

    before(:each) do
      @submission.update_attributes(status: "accepted")
      @submission.update_attributes(status_approved: true)
      ldap_sign_in(@admin)
    end

    it "should be initialized with an approved 'accepted' status" do
      expect(@submission.reload.status).to eq("accepted")
      expect(@submission.reload.status_approved).to eq(true)
    end

    context "visiting the submission page" do
      before(:each) { visit submission_path(@submission) }

      context "updating the submission's status" do
        before(:each) do
          check "submission_status_published"
          click_button "Update application status"
        end

        it "should change the submission's 'status_published' state" do
          expect(@submission.reload.status_published).to eq(true)
        end

        context "viewed by the advisor" do

          before(:each) do
            logout
            ldap_sign_in(@advisor)
          end

          it "should show the updated status on the submission's page" do
            visit submission_path(@submission)
            within('tr', text: "Status") do
              expect(page).to have_content("Accepted")
              expect(page).not_to have_content("Accepted (pending " +
                                               "administrator approval)")
            end
          end

          it "should show the updated status on the 'project's subs' page" do
            visit project_submissions_path(@project)
            within("table") do
              expect(page).to have_content("Accepted")
              expect(page).not_to have_content("Accepted (pending " +
                                               "administrator approval)")
            end
          end
        end

        context "viewed by the student" do
          before(:each) do
            logout
            ldap_sign_in(@student)
          end

          it "should be visible on the submission's page" do
            visit submission_path(@submission)
            within('tr', text: "Status") do
              expect(page).to have_content("Accepted")
              expect(page).not_to have_content("Pending")
            end
          end

          it "should be visible on the student's submission index page" do
            visit users_submissions_path(@student)
            within("table") do
              expect(page).to have_content("Accepted")
              expect(page).not_to have_content("Pending")
            end
          end
        end

        context "viewed by an admin" do
          # We're already signed in as an admin; no need to log out and sign
          # in again.

          it "should show the status dropdown and checkboxes on its page" do
            visit submission_path(@submission)
            within('tr', text: "Status") do
              expect(page).to have_select("Status", selected: "Accepted")
              expect(page.find("#submission_status_approved")).
                to be_checked
              expect(page.find("#submission_status_published")).
                to be_checked
            end
          end

          it "should show its status on the 'applications' page" do
            visit submissions_path
            within("table") do
              expect(page).not_to have_content("Accepted (pending " +
                                               "administrator approval)")
              expect(page).to have_content("Accepted")
            end
          end
        end

        context "viewed by another advisor" do
          before(:each) do
            logout
            ldap_sign_in(@other_advisor)
          end

          it "should redirect when trying to view the sub" do
            visit submission_path(@submission)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when visiting the user's subs pg" do
            visit users_submissions_path(@student)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

        context "viewed by another student" do
          before(:each) do
            logout
            ldap_sign_in(@other_student)
          end

          it "should redirect when trying to view the sub" do
            visit submission_path(@submission)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when visiting the user's subs pg" do
            visit users_submissions_path(@student)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

      end
    end
  end

  # We might want to put this in another spec file.
  # context "viewing the submission's status" do

  #   before(:each) { ldap_sign_in(@student) }

  # end

end
