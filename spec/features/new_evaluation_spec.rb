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
    @template = FactoryGirl.create(:evaluation_template)
    @project = FactoryGirl.create(:project, :accepted_and_published,
                                  :in_current_quarter, advisor: @advisor)
  end

  context "as the advisor" do

    before(:each) { ldap_sign_in(@advisor) }

    context "when the sub's status is accepted, approved, and published" do

      before(:each) do
        @submission = FactoryGirl.create(:submission, student: @student,
                                         project: @project,
                                         status: "accepted",
                                         status_approved: true,
                                         status_published: true)
      end

      context "visiting the submission page" do

        before(:each) { visit submission_path(@submission) }

        it "should land on the submission page" do
          expect(current_path).to eq(submission_path(@submission))
        end

        it "should see the 'new evaluation' link" do
          expect(page).
            to have_link("here", new_submission_evaluation_path(@submission))
        end

        # Note: there is no 'edit evaluation' feature.
        context "clicking the 'new evaluation' link" do

          before(:each) { within("#content") { click_link("here") } }

          it "should go to the 'new evaluation' page" do
            expect(current_path).
              to eq(new_submission_evaluation_path(@submission))
          end

          it "should see the appropriate form" do
            expect(page).to have_content("New Evaluation for " +
                                         @student.first_name + " " +
                                         @student.last_name)

            # We expect to see the evaluation template's questions.
            @template.survey.values.each do |question|
              expect(page).to have_content(question["question_prompt"])
            end
          end
        end

        context "filling out the 'new evaluation' form" do

          before(:each) { visit new_submission_evaluation_path(@submission) }

          context "with valid responses" do
            it "should be valid" do

              # Here we assume that all the question types are either
              # text areas or text fields. (See factories.rb.)

              # For a more rigorous test, we could use a case statement
              # to change how we "fill in" our response, based on the
              # question's type.

              # We could also choose to answer questions based on whether
              # they're mandatory.
              save_and_open_page
              @template.survey.values.each do |question|
                fill_in "survey[#{question["question_prompt"]}]", with: "a" * 50
              end
              expect{ click_button "Submit evaluation" }.
                to change{ Evaluation.count }.by(1)
            end
          end

          context "with invalid responses" do
            it "should be invalid" do
              # Here, we fill in none of the (mandatory) fields.
              expect{ click_button "Submit evaluation" }.
                to change{ Evaluation.count }.by(0)
            end
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

          it "should show the user the evaluation" do

          end

        end
      end

    end

    context "when the submission's status is not accepted and published" do
      context "visiting the submission's page" do
        it "should not have the 'new evaluation' link" do

        end
      end

      context "visiting the 'new evaluation' page for the submission" do
        it "should redirect the user to the homepage" do

        end
      end
    end

    context "visiting someone else's evaluation" do
      # Set up another advisor, project, submission, and evaluation, and
      # attempt to view it.

      it "should redirect the advisor to the homepage" do

      end
    end
  end

  # Test admins viewing submissions and evaluations?

end
