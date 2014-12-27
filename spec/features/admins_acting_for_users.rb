require 'rails_helper'
require 'spec_helper'

describe "Admins creating records for advisors and students", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before do
    @q1      = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                  :cannot_create_project,
                                  :cannot_create_submission,
                                  :earlier_start_date)
    @admin   = FactoryGirl.create(:admin)
    @advisor = FactoryGirl.create(:advisor)
    @student = FactoryGirl.create(:student)
    ldap_sign_in(@admin)
  end

  context "when an admin visits the new project page" do
    before { visit new_project_path(year: @q1.year, season: @q1.season) }

    it "should have a field for identifying the advisor" do
      expect(page).to have_field("Advisor")
    end

    context "when the admin fills out and submits the form" do
      before do
        fill_in "Title", with: "a"
        fill_in "Advisor", with: @advisor.email
        fill_in "Description", with: "a"
        fill_in "Expected deliverables", with: "a"
        fill_in "Prerequisites", with: "a"
      end

      it "should be valid and create the proposal" do
        expect { click_button "Create my proposal" }.
          to change{ Project.count }.by(1)
        expect(Project.find(1).advisor).to eq(@advisor)
      end
    end
  end

  context "when an admin visits a new application page" do
    before do
      @p = FactoryGirl.build(:project, advisor: @advisor,
                              quarter: @q1, status: "accepted",
                              status_published: true)
      @p.save(validate: false)
      visit q_path(@p, :new_project_submission)
    end

    it "should have a field for identifying the student" do
      expect(page).to have_field("Applicant")
    end

    context "when the admin fills out and submits the form" do
      before do
        fill_in "Applicant", with: @student.email
        fill_in "Interests", with: "a"
        fill_in "Qualifications", with: "a"
        fill_in "Courses", with: "a"
      end

      it "should be valid and create the proposal" do
        expect { click_button "Submit my application" }.
          to change{ Submission.count }.by(1)
        expect(Submission.find(1).student).to eq(@student)
      end
    end
  end
end
