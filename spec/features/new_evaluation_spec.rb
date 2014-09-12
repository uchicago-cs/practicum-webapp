require 'rails_helper'
require 'spec_helper'

describe "Creating an evaluation", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  # Deadlines are irrelevant to evaluations, so we won't consider separate
  # cases for evaluations here.

  before(:each) do
    @quarter  = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin    = FactoryGirl.create(:admin)
    @advisor  = FactoryGirl.create(:advisor)
    @student  = FactoryGirl.create(:student)
    @template = FactoryGirl.create(:evaluation_template)
    @project  = FactoryGirl.create(:project, :accepted_and_published,
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
            it "should be valid and send us to the evaluation" do

              # Here we assume that all the question types are either
              # text areas or text fields. (See factories.rb.)

              # For a more rigorous test, we could use a case statement
              # to change how we "fill in" our response, based on the
              # question's type.

              # We could also choose to answer questions based on whether
              # they're mandatory.
              @template.survey.values.each do |question|
                fill_in "survey[#{question["question_prompt"]}]", with: "a" * 50
              end
              expect{ click_button "Submit evaluation" }.
                to change{ Evaluation.count }.by(1)
              expect(current_path).to eq(evaluation_path(Evaluation.first))
              expect(page).to have_content("Evaluation for " +
                                           @student.first_name + " " +
                                           @student.last_name)
            end
          end

          context "with invalid responses" do
            it "should be invalid and keep us on the 'new' page" do
              # Here, we fill in none of the (mandatory) fields.
              expect{ click_button "Submit evaluation" }.
                to change{ Evaluation.count }.by(0)
              # The path isn't going to be the 'new_eval' path, because
              # we go through the #create method in the evals controller.
              # We only render 'new'; we don't redirect to it.
              # (See EvaluationsController#create.)
              expect(current_path).
                to eq(submission_evaluations_path(@submission))
              expect(page).to have_content("Evaluation was not submitted.")
              expect(page).to have_selector("div.alert.alert-danger")
            end
          end
        end

      end

      # i.e., when the advisor has already made an evaluation for this user
      context "when an evaluation has been made" do

        before(:each) do
          # In factories.rb, we put the advisor, project, and student id's
          # in a sequence, so they increment after each example. We specify
          # the id's here so that they match @advisor's and @student's.
          @evaluation = FactoryGirl.create(:evaluation,
                                           submission: @submission,
                                           advisor_id: @advisor.id,
                                           student_id: @student.id,
                                           project_id: @project.id)
        end

        it "should not see the 'new evaluation' link" do
          visit submission_path(@submission)
          new_path_ = new_submission_evaluation_path(@submission)
          expect(page).not_to have_css("a[href~='#{new_path_}']")
        end

        it "should go to the homepage when visiting the 'new eval' page" do
          visit new_submission_evaluation_path(@submission)
          expect(current_path).to eq(root_path)
          expect(page).to have_selector("div.alert.alert-danger")
          expect(page).to have_content("You have already submitted an " +
                                       "evaluation for this student.")
        end

        it "should see a link to the evaluation" do
          visit submission_path(@submission)
          expect(page).to have_link("here", evaluation_path(@evaluation))
        end

        context "clicking the evaluation link" do

          before(:each) do
            visit submission_path(@submission)
            within("#content") { click_link "here" }
          end

          it "should bring the advisor to the evaluation page" do
            expect(current_path).to eq(evaluation_path(@evaluation))
          end

          it "should show the user the evaluation" do
            @template.survey.values.each do |question|
              expect(page).to have_content(question["question_prompt"])
              expect(page).to have_content(question["question_answer"])
            end
          end
        end
      end
    end

    context "when the sub's status is not accepted, approved, and published" do

      before(:each) do
        # We can use (almost) any combination of the three "status"
        # attributes that is not "accepted", true, and true.
        @submission = FactoryGirl.create(:submission, student: @student,
                                         project: @project,
                                         status: "accepted",
                                         status_approved: false,
                                         status_published: false)
      end

      context "visiting the submission's page" do

        before(:each) { visit submission_path(@submission) }

        it "should not have the 'new evaluation' link" do
          expect(page).not_to have_content("Click here to create an " +
                                           "evaluation for this student.")
        end
      end

      context "visiting the 'new evaluation' page for the submission" do

        before(:each) { visit new_submission_evaluation_path(@submission) }

        it "should redirect the user to the homepage" do
          expect(current_path).to eq(root_path)
          expect(page).to have_content("Application status must be approved, " +
                                       "published, and accepted.")
          expect(page).to have_selector("div.alert.alert-danger")
        end
      end
    end

    context "visiting someone else's evaluation" do

      before(:each) do
        @advisor_2  = FactoryGirl.create(:advisor)
        @project_2  = FactoryGirl.create(:project, :accepted_and_published,
                                         :in_current_quarter,
                                         advisor: @advisor_2)
        @submission_2 = FactoryGirl.create(:submission, project: @project_2,
                                           student: @student,
                                           status: "accepted",
                                           status_approved: true,
                                           status_published: true)
        @evaluation_2 = FactoryGirl.create(:evaluation,
                                           submission: @submission_2,
                                           advisor_id: @advisor_2.id,
                                           student_id: @student.id,
                                           project_id: @project_2.id)
        visit evaluation_path(@evaluation_2)
      end

      it "should redirect the advisor to the homepage" do
        expect(current_path).to eq(root_path)
        expect(page).to have_content("Access denied")
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end
  end

  # Test admins viewing submissions and evaluations?

end
