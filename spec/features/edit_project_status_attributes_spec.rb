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
    @project    = FactoryGirl.create(:project, :in_current_quarter,
                                     advisor: @advisor, status: "pending",
                                     status_published: false)
  end

  context "before the admin does anything to the project" do
    context "as the admin" do
      before(:each) { ldap_sign_in(@admin) }

      context "visiting the project page" do
        it "should show a 'pending' status" do
          visit project_path(@project)
          expect(page).to have_content("Pending")
          expect(page).to have_content("Click here to edit this project's " +
                                       "information.")
        end
      end

      context "visiting the pending projects page" do
        it "should show a 'pending' status" do
          visit pending_projects_path
          expect(page).to have_content("Pending")
        end
      end

    end

    context "as the advisor" do
      before(:each) { ldap_sign_in(@advisor) }

      context "visiting the project page" do
        it "should show a 'pending' status" do
          visit project_path(@project)
          expect(page).to have_content("Pending")
          expect(page).to have_content("Click here to edit this project's " +
                                       "information.")
        end
      end

    end

    # Advisors shouldn't be able to visit the pending projects page.
    # Students shouldn't be able to visit either of the pages.

  end

  context "accepting or rejecting the project" do
    before(:each) { ldap_sign_in(@admin) }

    context "visiting the project page" do
      before(:each) { visit project_path(@project) }

      context "updating the project's status" do
        before(:each) do
          choose "Approve"
          click_button "Update project status"
        end

        it "should change the project's status" do
          expect(@project.reload.status).to eq("accepted")
        end

        context "viewed by the admin" do

        end

        context "viewed by the advisor" do

        end

        context "viewed by the student" do

        end

      end

    end


  end

  context "publishing the decision (accepted)" do

  end

  context "publishing the decision (rejected)" do

  end

  context "editing the proposal" do

  end

end
