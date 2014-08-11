require 'rails_helper'
require 'spec_helper'
require 'selenium-webdriver'

feature "Creating a project" do
  subject { page }

  context "before the deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      sign_in(@advisor)
      click_link("Propose a project")
    end

    describe "new project" do

      it "should have the 'new proposal' text" do
        expect(page).to have_content("new project proposal")
      end

      describe "with valid input" do
        it "should create successfully" do
          fill_in "Name", with: "Generic Project Name"
          fill_in "Description", with: "a"*500
          fill_in "Expected deliverables", with: "a"*500
          fill_in "Prerequisites", with: "a"*500
          expect{ click_button "Create my proposal" }.to \
            change{ Project.count }.by(1)

          @project = Project.order('created_at DESC').first
          expect(@project.status).to eq "pending"
          expect(@project.status_published).to eq false
        end
      end

      describe "with invalid input" do
        it "should not create when project with its name exists" do
          FactoryGirl.create(:project, :in_current_quarter, \
                             name: "Generic Project Name")
          fill_in "Name", with: "Generic Project Name"
          fill_in "Description", with: "a"*500
          fill_in "Expected deliverables", with: "a"*500
          fill_in "Prerequisites", with: "a"*500
          expect{ click_button "Create my proposal" }.to \
            change{ Project.count }.by(0)
          expect(page).to have_selector('div.alert.alert-error')
        end

        it "should not create when one of its fields is too short" do
          fill_in "Name", with: "Generic Project Name"
          fill_in "Description", with: "a"*99
          fill_in "Expected deliverables", with: "a"*100
          fill_in "Prerequisites", with: "a"*100
          expect{ click_button "Create my proposal" }.to \
            change{ Project.count }.by(0)
          expect(page).to have_selector('div.alert.alert-error')
        end
      end

    end

  end

  context "after the deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :all_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      sign_in(@advisor)

    end

    describe "clicking the proposal creation link" do
      it "should redirect the user to the home page" do
        click_link("Propose a project")
        expect(current_path).to eq root_path
        expect(page).to have_selector('div.alert')
        expect(page).to have_content("About the Practicum program")
      end
    end

    # describe "creating a project with valid input" do
    #   it "should not create" do
    #   end
    # end
  end

end

feature "Project visibility" do
  subject { page }

  context "pending project" do

    before do
      @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      @admin = FactoryGirl.create(:admin)
    end

    describe "after the advisor fills out the form and hits submit" do
      before do
        sign_in(@advisor)
        click_link("Propose a project")
        fill_in "Name", with: "Generic Project Name"
        fill_in "Description", with: "a"*500
        fill_in "Expected deliverables", with: "a"*500
        fill_in "Prerequisites", with: "a"*500
        click_button "Create my proposal"
        @project = Project.where(advisor_id: @advisor.id).take
      end

      it "should have created a project" do
        expect(Project.count).to eq 1
      end

      # Note: these specs should test for the presence of "pending"
      # and the project's name in specific table cells, since it's possible
      # for the project description / information to include "pending"
      # and the project's name.

      it "should have a 'pending' and unpublished status" do
        expect(@project.status).to eq "pending"
        expect(@project.status_published).to eq false
      end

      it "should show 'pending' to the advisor" do
        click_link("My projects")
        click_link(@project.name)
        within("table") do
          expect(page).to have_content("Pending")
        end
      end

      it "should not be in the published projects list" do
        click_link("Projects")
        expect(page.text).not_to have_content(@project.name)
      end

      describe "an admin viewing the project" do
        before do
          click_link("Sign out")
          sign_in(@admin)
          click_link("Pending projects")
        end

        it "should show 'pending'" do
          within("table") do
            expect(page).to have_content("Pending")
          end
        end

        describe "an admin changing its status to 'accepted'" do
          before do
            click_link(@project.name)
            #click_link("Click here to change this project's status")
            find(:linkhref, edit_status_project_path(@project)).click
            choose "Approve"
            click_button "Update project status"
            save_and_open_page
            page.driver.browser.switch_to.alert.accept
          end

          it "should have changed its status to 'accepted'" do
            expect(@project.status).to eq "accepted"
          end

          it "should show 'accepted / pending' message on its page" do
            expect(page).to have_selector('div.alert.alert-notice')
            within("table") do
              expect(page).to have_content("Accepted (flagged")
            end
          end

          it "should show 'accepted / pending' on pendng projects page" do
            before { click_link "Pending projects" }
            within("table") do
              expect(page).to have_content("Accepted (flagged")
            end
          end
        end
      end

    end

    # it "should not have a publishable status" do ...
  end

end
