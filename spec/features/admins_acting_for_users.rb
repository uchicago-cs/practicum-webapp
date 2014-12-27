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
        fill_in "Title", with: "abcabcabc"
        fill_in "Advisor", with: @advisor.email
        fill_in "Description", with: "defdefdef"
        fill_in "Expected deliverables", with: "ghighighi"
        fill_in "Prerequisites", with: "jkljkljkl"
      end

      it "should create the proposal and be visible to the advisor" do
        expect { click_button "Create my proposal" }.
          to change{ Project.count }.by(1)
        expect(Project.find(1).advisor).to eq(@advisor)
        logout
        ldap_sign_in(@advisor)
        visit q_path(Project.find(1))
        expect(current_path).to eq(q_path(Project.find(1)))
        expect(page).to have_content("jkljkljkl")
        visit users_projects_path(year: @q1.year, season: @q1.season)
        expect(current_path).to eq(users_projects_path(year: @q1.year,
                                                       season: @q1.season))
        expect(page).to have_content("abcabcabc")
        visit users_projects_all_path(@advisor)
        expect(current_path).to eq(users_projects_all_path(@advisor))
        expect(page).to have_content("abcabcabc")
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
        fill_in "Interests", with: "abcdefg"
        fill_in "Qualifications", with: "hijklmnop"
        fill_in "Courses", with: "qrstuv"
      end

      it "should create the submission and be visible to the student" do
        expect { click_button "Submit my application" }.
          to change{ Submission.count }.by(1)
        expect(Submission.find(1).student).to eq(@student)
        logout
        ldap_sign_in(@student)
        visit q_path(Submission.find(1))
        expect(current_path).to eq(q_path(Submission.find(1)))
        expect(page).to have_content("qrstuv")
        visit users_submissions_path(year: @q1.year, season: @q1.season)
        expect(current_path).to eq(users_submissions_path(year: @q1.year,
                                                          season: @q1.season))
        expect(page).to have_content(@p.name)
        visit users_submissions_all_path(@student)
        expect(current_path).to eq(users_submissions_all_path(@student))
        expect(page).to have_content(@p.name)
      end
    end
  end
end
