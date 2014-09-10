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
      before(:each) do
        @project = FactoryGirl.create(:project, :in_current_quarter,
                                      advisor: @advisor)
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

    describe "an admin viewing the project" do

      before do
        @project = FactoryGirl.create(:project, :in_current_quarter,
                                      advisor: @advisor)
      end

      it "should show 'pending'" do
        ldap_sign_in(@admin)
        visit root_path
        within("#dropdown-administrative") { click_link("Pending projects") }
        within("table") do
          expect(page).to have_content("Pending")
        end
      end
    end

    describe "an admin changing its status to 'accepted'" do

      before(:each) do
        # These _need_ to be :in_current_quarter.
        @project = FactoryGirl.create(:project, :in_current_quarter,
                                      advisor: @advisor)
        ldap_sign_in(@admin)
        visit pending_projects_path
        page.find_link(@project.name).click
        choose "Approve"
        click_button "Update project status"
      end

      it "should have a success message" do
        expect(page).to have_css(".alert.alert-success")
      end

      it "should have changed its status to 'accepted'" do
        # The #reload is necessary: we need to grab the updated value.
        expect(@project.reload.status).to eq "accepted"
      end

      it "should have 'Approve' selected on its page" do
        within("table") do
          expect(page).to have_checked_field("Approve")
        end
      end

      it "should show 'accepted / pending' on pendng projects page" do
        click_link "Pending projects"
        within("table") do
          expect(page).to have_content("Accepted (flagged, not published)")
        end
      end

      it "should not have a published status" do
        expect(@project.reload.status_published).to eq false
      end

    end

    # it "should not have a published status" do ...
  end

end
