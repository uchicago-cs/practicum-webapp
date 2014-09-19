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
    # @project       = FactoryGirl.create(:project, :in_current_quarter,
    #                                     advisor: @advisor, status: "accepted",
    #                                     status_published: true)
  end

  context "visiting the 'new project' page" do

    before(:each) do
      ldap_sign_in(@advisor)
      visit new_project_path
    end

    it "should show the 'save as draft' button" do
      expect(page).to have_button "Save as draft"
    end

    context "saving the proposal as a draft" do

      before(:each) do
        fill_in "Prerequisites", with: "a" * 5
        click_button "Save as draft"
      end

      it "should save the information to the database" do
        expect(Project.first.name).to                  eq("")
        expect(Project.first.description).to           eq("")
        expect(Project.first.expected_deliverables).to eq("")
        expect(Project.first.related_work).to          eq("")
        expect(Project.first.prerequisites).to         eq("a" * 5)
      end

      it "should redirect the advisor to their projects page" do
        expect(current_path).to eq(users_projects_path(@advisor))
      end

      it "should appear to the advisor on their projects page" do
        # We should check within the exact cell.
        within("table") do
          expect(page).to have_content("Draft")
          expect(page).not_to have_content("Pending")
        end
      end

      it "should be editable via the projects page" do
        # Click the link to the project's page.
        within("table") do
          click_link "here"
        end

        expect(current_path).to eq(edit_project_path(Project.first))
      end

      it "should display the 'edit' link on the project's page" do
        within("table") do
          click_link "here"
        end

        expect(page).to have_button("Create my proposal")
        expect(page).to have_button("Save as draft")
      end

      context "viewing the site as a different user" do

        before(:each) { logout }

        context "as an admin" do

          before(:each) do
            ldap_sign_in(@admin)
          end

          it "should be viewable and show the 'edit' link" do
            visit users_projects_path(@advisor)
            within("table") do
              expect(page).to have_content(Project.first.name)
              # We expect to see the 'edit' link.
              expect(page).to have_link("here")
              click_link("here")
            end

            expect(current_path).to eq(edit_project_path(Project.first))
            expect(page).to have_button("Create my proposal")
            expect(page).to have_button("Save as draft")
          end

          it "should not be visible on the projects page" do
            visit projects_path
            # We test for the presence of the project's advisor's name.
            expect(page).not_to have_content(@advisor.first_name + " " +
                                             @advisor.last_name)
          end

          it "should not be visible on the 'pending projects' page" do
            visit pending_projects_path
            expect(page).not_to have_content(@advisor.first_name + " " +
                                             @advisor.last_name)
          end

        end

        context "as a student" do

          before(:each) { ldap_sign_in(@student) }

          it "should not be visible on the projects page" do
            visit projects_path
            # We test for the presence of the project's advisor's name.
            expect(page).not_to have_content(@advisor.first_name + " " +
                                             @advisor.last_name)
          end

          it "should redirect when trying to view project" do
            visit project_path(Project.first)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when trying to edit the project" do
            visit edit_project_path(Project.first)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

        context "as another advisor" do

          before(:each) { ldap_sign_in(@other_advisor) }

          it "should not be visible on the projects page" do
            visit projects_path
            # We test for the presence of the project's advisor's name.
            expect(page).not_to have_content(@advisor.first_name + " " +
                                             @advisor.last_name)
          end

          it "should redirect when trying to view project" do
            visit project_path(Project.first)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

          it "should redirect when trying to edit the project" do
            visit edit_project_path(Project.first)
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
            expect(page).to have_content("Access denied")
          end

        end

      end

      # Returning to it later as the advisor
      context "returning to it later" do

        it "should show its info on the project's page"

        it "should show its info on the project's 'edit' page"

        context "submitting it" do

          it "should change the project's status"

          it "should redirect the advisor to their projects page"

          it "shold show the project as 'pending' on their projects page"

          it "should appear on the 'pending projects' page"

          it "should still be editable by the advisor while it is 'pending'"

        end

      end

    end

  end

end
