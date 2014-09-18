require 'rails_helper'
require 'spec_helper'

describe "Drafting a submission", type: :feature do
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
    @project       = FactoryGirl.create(:project, :in_current_quarter,
                                        advisor: @advisor, status: "accepted",
                                        status_published: true)
  end

  context "visiting the 'new submission' page" do

    # Sign in and visit the page

    before(:each) do
      ldap_sign_in(@student)
      visit new_project_submission_path(@project)
    end

    it "should show the 'save as draft' button" do
      expect(page).to have_button("Save as draft")
    end

    context "saving the submission as a draft" do

      before(:each) do
        fill_in "Interests", with: "a" * 5
      end

      it "should save the information to the database" do
        expect { click_button "Save as draft" }.
          to change{ Submission.count }.by(1)
        expect(Submission.first.information).to eq("a" * 5)
        expect(Submission.first.qualifications).to eq("")
        expect(Submission.first.courses).to eq("")
      end

      it "should redirect the student to their submissions page" do
        click_button "Save as draft"
        expect(current_path).to eq(users_submissions_path(@student))
      end

      it "should appear to the student on their submissions page" do
        click_button "Save as draft"
        # We should be redirected to `users_submissions_path(@student)`.
        within "table" do
          expect(page).to have_content(@project.name)
          expect(page).to have_content("Draft (unsubmitted)")
        end
      end

      it "should be editable via the submissions page" do
        click_button "Save as draft"
        # Click the link to go to the 'edit' page.
        within "table" do
          expect(page).to have_content("edit")
          click_link("here")
        end

        expect(page).to have_content("Edit Application for #{@project.name}")
        within "table" do
          expect(page).to have_field("Information", with: "a" * 5)
          expect(page).to have_field("Qualifications", with: "")
          expect(page).to have_field("Courses", with: "")
          expect(page).to have_content("No resume uploaded")
        end
      end

      it "should be visible to the admin" do
        click_button "Save as draft"
        logout
        ldap_sign_in(@admin)
        visit users_submissions_path(@student)
        within("table") do
          expect(page).to have_content(@project.name)
          expect(page).to have_content("Draft")
        end
        visit submissions_path
        within("table") do
          expect(page).to have_content(@project.name)
          expect(page).to have_content("Draft")
        end
      end

      context "viewing the site as the advisor" do

        before(:each) do
          click_button "Save as draft"
          logout
          ldap_sign_in(@advisor)
        end

        it "should not be visible via the \"@project's submissions\" page" do
          visit users_projects_path(@advisor)
          within("table") do
            click_link("here")
          end
          expect(page).not_to have_content(@student.first_name + " " +
                                           @student.last_name)
          expect(page).not_to have_content("Draft")
        end

        it "should redirect when visiting the submission's page" do
          visit submission_path(Submission.first)
          expect(current_path).to eq(root_path)
          expect(page).to have_selector("div.alert.alert-danger")
          expect(page).to have_content("Access denied")
        end

        it "should redirect when visiting the submission's edit page" do
          visit edit_submission_path(Submission.first)
          expect(current_path).to eq(root_path)
          expect(page).to have_selector("div.alert.alert-danger")
          expect(page).to have_content("Access denied")
        end

        it "should not include the # of drafts in the project's apps count" do
          visit project_path(@project)
          # This should be tested within the td cell that has the number.
          within("table") do
            expect(page).to have_content(@project.submitted_submissions.count)
          end
        end
      end

      context "returning to it later" do

        before(:each) do
          click_button "Save as draft"
          logout
          ldap_sign_in(@student)
          visit submission_path(Submission.first)
        end

        it "should show the info the user entered" do
          # This should be tested cell by cell.
          within("table") do
            expect(page).to have_content("a" * 5)
            expect(page).to have_content("Draft (unsubmitted)")
          end
        end

        it "should show the info the user entered on the 'edit' page" do
          within("#content") do
            click_link "here"
          end

          expect(page).to have_content("Edit Application for #{@project.name}")
          within "table" do
            expect(page).to have_field("Information", with: "a" * 5)
            expect(page).to have_field("Qualifications", with: "")
            expect(page).to have_field("Courses", with: "")
            expect(page).to have_content("No resume uploaded")
          end

        end

        it "should show an 'edit' link on the submission's page" do
          within("#content") do
            expect(page).to have_content("Click here to continue editing " +
                                         "and / or submit this application.")
            expect(page).
              to have_link("here",
                           href: edit_submission_path(Submission.first))
          end
        end

        context "submitting it" do

          before(:each) do
            within("#content") do
              click_link "here"
            end
            fill_in "Qualifications", with: "b" * 2
            fill_in "Courses", with: "c" * 4
            click_button "Submit my application"
          end

          it "should change the submission's status" do
            expect(Submission.first.status).to   eq("pending")
            expect(Submission.first.pending?).to eq(true)
            expect(Submission.first.draft?).to   eq(false)
          end

          it "should redirect the user to their submissions page" do
            expect(current_path).to eq(users_submissions_path(@student))
            expect(page).to have_selector("div.alert.alert-success")
            expect(page).to have_content("submitted")
          end

          it "should show the submission as 'pending' on their subs page" do
            within("table") do
              expect(page).to have_content("Pending")
            end
          end

          it "should not be editable by the student" do
            visit edit_submission_path(Submission.first)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("You cannot edit a submitted " +
                                         "application")
          end

          it "should not show the 'edit' link on the sub's page" do
            within("#content") do
              expect(page).
                not_to have_content("Click here to continue editing and / " +
                                    "or submit this application.")
              expect(page).
                not_to have_link("here",
                                 href: edit_submission_path(Submission.first))
            end
          end

          it "should not be editable by the advisor" do
            logout
            ldap_sign_in(@advisor)
            visit edit_submission_path(Submission.first)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should not show the 'edit' link to the advisor" do
            logout
            ldap_sign_in(@advisor)
            visit submission_path(Submission.first)
            within("#content") do
              expect(page).
                not_to have_content("Click here to continue editing and / " +
                                    "or submit this application.")
              expect(page).
                not_to have_link("here",
                                 href: edit_submission_path(Submission.first))
            end
          end

          # Admins may edit submitted submissions.

          context "viewing the site as the advisor" do

            before(:each) do
              logout
              ldap_sign_in(@advisor)
            end

            it "should appear via the \"@project's submissions\" page" do
              visit users_projects_path(@advisor)
              within("table") do
                click_link "here"
              end
              expect(page).to have_content(@student.first_name + " " +
                                           @student.last_name)
            end
          end
        end
      end
    end
  end
end
