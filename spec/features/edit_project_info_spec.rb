require 'rails_helper'
require 'spec_helper'

describe "Editing a project's information", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter    = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin      = FactoryGirl.create(:admin)
    @advisor    = FactoryGirl.create(:advisor)
    @student    = FactoryGirl.create(:student)
    @project    = FactoryGirl.create(:project, :in_current_quarter,
                                     advisor: @advisor, status: "pending",
                                     status_published: false)
  end

  # Things to test:
  # - When it can and cannot be done (not related to quarters, but to its
  # status)
  # - Ensure that other advisors cannot edit the project

  # We do this just as the advisor rather than as both the advisor and the
  # admin.

  context "when the proposal is pending and unpublished" do

    context "visiting the project's page" do

      it "should have the 'edit proposal' link" do
        ldap_sign_in(@advisor)
        visit project_path(@project)
        within("#content") do
          expect(page).to have_link("here")
          expect(page).to have_content("Click here to edit this " +
                                       "project's information.")
        end
      end
    end

    context "editing the proposal" do
      context "with valid information" do
        before(:each) do
          ldap_sign_in(@advisor)
          visit project_path(@project)
          within("#content") { click_link "here" }
          fill_in "Name", with: "New title"
          fill_in "Description", with: "test " * 50
          fill_in "Related work", with: ""
          click_button "Edit my proposal"
        end

        it "should update the project information" do
          expect(@project.reload.name).to eq("New title")
          expect(@project.reload.description).to eq("test " * 50)
          expect(@project.reload.related_work).to eq("")
        end

        context "as the advisor" do

          it "should be valid" do
            expect(current_path).to eq(project_path(@project))
            expect(page).to have_selector("div.alert.alert-success")
            expect(page).to have_content("Project proposal successfully " +
                                         "updated.")
          end

          it "should show the updated information" do
            within('tr', text: "Title") do
              expect(page).to have_content("New title")
            end

            within('tr', text: "Description") do
              expect(page).to have_content("test " * 50)
            end

            within('tr', text: "Related work") do
              expect(page).to have_content("N/A")
            end
          end
        end

        context "as the admin" do
          before(:each) do
            logout
            ldap_sign_in(@admin)
          end

          it "should show the updated information" do
            visit project_path(@project)
            within('tr', text: "Title") do
              expect(page).to have_content("New title")
            end

            within('tr', text: "Description") do
              expect(page).to have_content("test " * 50)
            end

            within('tr', text: "Related work") do
              expect(page).to have_content("N/A")
            end
          end
        end
      end

      context "with an invalid title" do
        before(:each) do
          ldap_sign_in(@advisor)
          visit project_path(@project)
          within("#content") { click_link "here" }
          fill_in "Name", with: ""
          click_button "Edit my proposal"
        end

        it "should not update the project" do
          expect(@project.reload.name).not_to eq("")
          expect(@project.reload.name).to include("Project")
        end

        it "should show the advisor an error message" do
          # We're on the `create` path (which is the project's path) but we
          # have rendered `new`.
          expect(current_path).to eq(project_path(@project))
          expect(page).to have_content("error")
          expect(page).to have_content("Name can't be blank")
          expect(page).to have_selector("div.alert.alert-danger")
        end
      end

      context "with an invalid description" do
        before(:each) do
          ldap_sign_in(@advisor)
          visit project_path(@project)
          within("#content") { click_link "here" }
          fill_in "Description", with: "test"
          click_button "Edit my proposal"
        end

        it "should not update the project" do
          expect(@project.reload.description).not_to eq("test")
          expect(@project.reload.description).to eq("a"*500)
        end

        it "should show the advisor an error message" do
          expect(current_path).to eq(project_path(@project))
          expect(page).to have_content("error")
          expect(page).to have_content("Description is too short")
          expect(page).to have_selector("div.alert.alert-danger")
        end
      end
    end
  end

  context "when the proposal is unpublished and not pending" do

    before(:each) do
      @project.this_user = @admin
      @project.update_attributes(status: "accepted")
      @project.reload
    end

    context "as the advisor" do
      before(:each) { ldap_sign_in(@advisor) }

      context "visiting the project page" do
        before(:each) { visit project_path(@project) }

        it "should not have the 'edit proposal' link" do
          within("#content") do
            expect(page).not_to have_link("here")
            expect(page).not_to have_content("Click here to edit this " +
                                             "project's information.")
          end
        end
      end

      context "visiting the advisor's 'my_projects'  page" do
        before(:each) { visit project_path(@project) }

        it "should not have the 'edit proposal' link" do
          save_and_open_page
          within("#content") do
            expect(page).not_to have_link("here")
            expect(page).not_to have_content("edit")
          end
        end
      end
    end

    # Admins should still be able to see the link and edit the project,
    # but we don't need to test whether this is so.
  end

  context "when the proposal is published and not pending" do

    before(:each) do
      @project.this_user = @admin
      @project.update_attributes(status: "accepted")
      @project.update_attributes(status_published: true)
      @project.reload
    end

    context "as the advisor" do
      before(:each) { ldap_sign_in(@advisor) }

      context "visiting the project page" do
        before(:each) { visit project_path(@project) }

        it "should not have the 'edit proposal' link" do
          within("#content") do
            expect(page).not_to have_link("here")
            expect(page).not_to have_content("Click here to edit this " +
                                             "project's information.")
          end
        end
      end

      context "visiting the advisor's 'my_projects'  page" do
        before(:each) { visit project_path(@project) }

        it "should not have the 'edit proposal' link" do
          save_and_open_page
          within("#content") do
            expect(page).not_to have_link("here")
            expect(page).not_to have_content("edit")
          end
        end
      end
    end
  end

end
