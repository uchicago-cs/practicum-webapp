require 'rails_helper'
require 'spec_helper'

describe "Creating a submission", type: :feature do

  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  context "before the submission deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
      @year    = @quarter.year
      @season  = @quarter.season
      @admin   = FactoryGirl.create(:admin)
      @advisor = FactoryGirl.create(:advisor)
      @student = FactoryGirl.create(:student)
      @project = FactoryGirl.create(:project, :accepted_and_published,
                                    :in_current_quarter, advisor: @advisor)
      ldap_sign_in(@student)
    end

    describe "the student viewing the project" do

      before(:each) { visit projects_path(year: @year, season: @season) }

      it "should see the deadline on the projects page" do
        expect(page).to have_selector("div.alert.alert-info")
        within(".alert.alert-info") do
          expect(page).to have_content("Application deadline:")
        end
      end

      it "should see the project on the projects page" do
        within("table") do
          expect(page).to have_content(@project.name)
        end
      end

      it "should see the project information on the project's page" do
        click_link(@project.name)
        # We're testing only the project's name...
        within("table") do
          expect(page).to have_content(@project.name)
        end
      end

      # This should happen _only_ before the application deadline!
      it "should see the 'new application' button on the project's page" do
        click_link(@project.name)
        expect(page).to have_content("Click here to apply")
      end

      it "should go to the 'new application' page after clicking the button" do
        click_link(@project.name)
        page.find("#new-submission-link").click
        expect(page).to have_content("Apply to " + @project.name)
      end

    end

    describe "the student creating a submission" do

      before(:each) do
        visit q_path(@project, :new_project_submission)
      end

      describe "the student correctly filling out the application form" do

        before(:each) do
          fill_in "Interests", with: "a" * 500
          fill_in "Qualifications", with: "a" * 500
          fill_in "Courses", with: "a" * 500
          click_button "Submit my application"
        end

        it "should redirect the student to their submitted apps page" do
          expect(page).to have_selector("div.alert.alert-success")
          expect(page).to have_content(@project.name)
        end

        it "should see a link to the application" do
          expect(page).to have_link("here", href: q_path(Submission.first))
        end

        it "should see the app information after clicking the app link" do
          within("table") do
            click_link("here")
          end
          expect(page).to have_content(@student.first_name + " " +
                                       @student.last_name +
                                       "'s Application to " + @project.name)
          within("#status") do
            expect(page).to have_content("Pending")
          end
          within("#interests") do
            expect(page).to have_content("a" * 500)
          end
          within("#qualifications") do
            expect(page).to have_content("a" * 500)
          end
          within("#courses") do
            expect(page).to have_content("a" * 500)
          end
        end

        it "should not see the update text after clicking the app link" do
          within("table") do
            click_link("here")
          end

          within("#status") do
            expect(page).not_to have_content("Status approved?")
            expect(page).not_to have_content("Status published?")
            expect(page).not_to have_button("Update application status")
          end
        end
      end

      describe "the student incorrectly filling out the application form" do
        before(:each) do
          fill_in "Interests", with: "a" * 5
          fill_in "Qualifications", with: "a" * 1
        end

        it "should not create the submission" do
          expect{ click_button "Submit my application" }.
            to change{ Submission.count }.by(0)
        end

        it "should show the user an error message" do
          click_button "Submit my application"
          # We go through the #create action and render 'new', so we are on
          # the project_submissions_path for @project.
          expect(current_path).to eq(q_path(@project, :project_submissions))
          expect(page).to have_selector("div.alert.alert-danger")
          expect(page).to have_content("error")
        end

      end

      describe "the student applying to the same project twice" do
        before(:each) do
          # Submit the first (valid) application.
          fill_in "Interests", with: "a" * 500
          fill_in "Qualifications", with: "a" * 500
          fill_in "Courses", with: "a" * 500
          click_button "Submit my application"
        end

        describe "visiting the 'new application' link" do
          it "should redirect the student" do
            visit q_path(@project, :new_project_submission)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("already applied")
          end
        end

        describe "directly making the application" do
          it "should not be valid" do
            @submission = FactoryGirl.build(:submission, student: @student,
                                            project: @project,
                                            status: "pending",
                                            status_approved: false,
                                            status_published: false)
            expect(@submission).not_to be_valid
          end
        end
      end
    end

  end

  context "after the submission deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :can_create_project,
                                    :cannot_create_submission,
                                    :earlier_start_date, :later_end_date)
      @year    = @quarter.year
      @season  = @quarter.season
      @admin   = FactoryGirl.create(:admin)
      @advisor = FactoryGirl.create(:advisor)
      @student = FactoryGirl.create(:student)
      @project = FactoryGirl.create(:project, :accepted_and_published,
                                    :in_current_quarter, advisor: @advisor)
      ldap_sign_in(@student)
    end

    describe "the student viewing the project" do

      before(:each) { visit projects_path(year: @year, season: @season) }

      it "should see a notification that the deadline has passed" do
        expect(page).to have_selector("div.alert.alert-warning")
        within(".alert.alert-warning") do
          expect(page).to have_content("The application deadline for this " +
                                       "quarter has passed.")
        end
      end

      it "should not see the 'apply to this project' text" do
        expect(page).not_to have_content("Click here to apply.")
      end

      it "should be redirected away when visiting the new sub. url" do
        visit q_path(@project, :new_project_submission)
        expect(page).to have_selector("div.alert.alert-danger")
        expect(page).to have_content("The application deadline for this " +
                                     "quarter has passed.")
        expect(current_path).to eq(root_path)
      end
    end
  end

  describe "the student applying to a project from a different quarter" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      @student = FactoryGirl.create(:student)
      @q2 = FactoryGirl.create(:quarter, :inactive_and_deadlines_passed,
                               season: "spring")
      @project_2 = FactoryGirl.build(:project, :accepted_and_published,
                                     quarter: @q2, advisor: @advisor)
      @project_2.save(validate: false)
      ldap_sign_in(@student)
    end

    it "should not show the 'apply' button on the project's page" do
      visit q_path(@project_2)
      expect(page).not_to have_content("Click here to apply")
    end

    it "should redirect the student visiting the project's 'apply' page" do
      visit q_path(@project_2, :new_project_submission)
      expect(current_path).to eq(root_path)
      expect(page).to have_selector("div.alert.alert-danger")
      expect(page).to have_content("That project was offered in a previous " +
                                   "quarter and is no longer available.")
    end

    it "should prevent a direct creation" do
      @submission = @project_2.submissions.build(student: @student,
                                                 information: "a",
                                                 qualifications: "a",
                                                 courses: "a")
      expect(@submission).not_to be_valid
      expect(@submission.errors.full_messages).
        to include("Applications cannot be submitted to projects from " +
                   "previous quarters.")
    end

  end

end
