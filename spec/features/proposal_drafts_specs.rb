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

    end

  end

end
