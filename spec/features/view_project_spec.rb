require 'rails_helper'
require 'spec_helper'

describe "Viewing a project", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  context "pending project" do

    before do
      @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      @admin = FactoryGirl.create(:admin)
    end

    describe "after the advisor fills out the form and hits submit" do
      before do
        ldap_sign_in(@advisor)
        visit new_project_url
      end

      it "should have created a project" do
        fill_in "project_name", with: "Generic Project Name"
        fill_in "Description", with: "a"*500
        fill_in "Expected deliverables", with: "a"*500
        fill_in "Prerequisites", with: "a"*500
        expect { click_button "Create my proposal" }.
          to change{ Project.count }.by(1)
      end
    end

    describe "after the advisor has made a project" do
      before do
        @project = FactoryGirl.create(:project, advisor: @advisor)
        ldap_sign_in(@advisor)
        visit root_url
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
        within("#dropdown-personal") { click_link("My projects") }
        click_link(@project.name)
        within("table") do
          expect(page).to have_content("Pending")
        end
      end

      it "should not be in the published projects list" do
        click_link("Projects")
        expect(page.text).not_to have_content(@project.name)
      end
    end

    context "an admin viewing the project" do

      it "should show 'pending'" do
        @project = FactoryGirl.create(:project, advisor: @advisor)
        ldap_sign_in(@admin)
        visit root_path
        within("#dropdown-administrative") { click_link("Pending projects") }
        within("table") do
          expect(page).to have_content("Pending")
        end
      end

      describe "an admin changing its status to 'accepted'", js: true do
        before do
          @project = FactoryGirl.create(:project, advisor: @advisor)
          ldap_sign_in(@admin)
          visit root_path
          visit pending_projects_path
          click_link(@project.name)
          choose "Approve"
          click_button "Update project status"
          page.evaluate_script('window.confirm = function() { return true; }')
        end

        it "should have changed its status to 'accepted'" do
          puts @project.inspect * 50
          expect(@project.status).to eq "accepted"
        end

        # it "should show 'accepted / pending' message on its page" do
        #   expect(page).to have_selector('div.alert.alert-notice')
        #   within("table") do
        #     expect(page).to have_content("Accepted (flagged")
        #   end
        # end

      #     it "should show 'accepted / pending' on pendng projects page" do
      #       before do
      #         click_link "Pending projects"
      #       end
      #       within("table") do
      #         expect(page).to have_content("Accepted (flagged")
      #       end
      #     end
        end
       end

    # end

    # it "should not have a publishable status" do ...
  end

end
