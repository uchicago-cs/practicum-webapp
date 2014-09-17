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

    it "should show the 'save as draft' button"

    context "saving the submission as a draft" do

      it "should save the information to the database"

      it "should appear to the student on their submissions page"

      it "should be editable via submissions page"

      it "should be visible to the admin"

      context "viewing the site as the advisor" do

        it "should not be visible via the 'my projects' page"

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
