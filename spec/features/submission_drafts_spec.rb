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

        it "should not be visible via the 'my projects' page" do
          visit users_projects_path(@advisor)
          within("table") do
            click_link("here")
            save_and_open_page
          end
        end

        it "should redirect when visiting the submission's page"

        it "should redirect when visiting the submission's edit page"

      end

      context "returning to it later" do

        it "should show the information the user entered"

        context "submitting it" do

          # Click the 'submit' button

          it "should not be editable by the admin, advisor, or student"

          context "viewing the site as the advisor" do

            it "should appear via the 'my projects' page"

          end
        end
      end
    end
  end
end
