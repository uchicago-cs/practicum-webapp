require 'rails_helper'
require 'spec_helper'

describe "Creating an evaluation", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  # Deadlines are irrelevant to evaluations, so we won't consider separate
  # cases for evaluations here.

  before(:each) do
    @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin   = FactoryGirl.create(:admin)
    @advisor = FactoryGirl.create(:advisor)
    @student = FactoryGirl.create(:student)
    @project = FactoryGirl.create(:project, :accepted_and_published,
                                  :in_current_quarter, advisor: @advisor)
    @submission = FactoryGirl.create(:submission, project: @project)
    ldap_sign_in(@advisor)
  end

  # All of these are true for the admin, as well. -> DRY it up.
  context "as the advisor" do
    context "visiting the submission page" do

      it "should see the 'new evaluation' link" do

      end

      context "clicking the 'new evaluation' link" do
        it "should go to the 'new evaluation' page" do

        end

        it "should see the appropriate form" do

        end
      end

      context "filling out the 'new evaluation' form" do
        context "with valid inputs" do
          it "should be valid" do

          end
        end

        context "with invalid inputs" do
          it "should be invalid"
        end
      end

    end

    # i.e., when the advisor has already made an evaluation for this user
    context "when an evaluation has been made" do

      it "should not see the 'new evaluation' link" do

      end

      it "should go to the homepage when visiting the 'new evaluation' page" do

      end

      it "should see a link to the evaluation" do

      end

      context "clicking the evaluation link" do

        it "should bring the advisor to the evaluation page" do

        end

        it "should show the advisor the evaluation" do

        end

      end
    end
  end

  context "as the admin" do
    context "visitng the submission page" do

    end

    context
  end

end
