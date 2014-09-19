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

    it "should show the 'save as draft' button"

    context "saving the proposal as a draft" do

      it "should save the information to the database"

      it "should redirect the advisor to their projects page"

      it "should appear to the advisor on their projects page"

      it "should be editable via the projects page"

      it "should display the 'edit' link on the project's page"

      it "should be visible to the admin"

      it "shouold not be visible on the projects page"

      it "should not be visible on the 'pending projects' page"

      context "viewing the site as a different user" do

        context "as a student" do

          it "should not be visible on the projects page"

          it "should not be visible on the 'pending projects' page"

          it "should redirect when trying to view project"

          it "should redirect when trying to edit the project"

        end

        context "as another advisor" do

          it "shouold not be visible on the projects page"

          it "should not be visible on the 'pending projects' page"

          it "should redirect when trying to view project"

          it "should redirect when trying to edit the project"

        end

      end

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
