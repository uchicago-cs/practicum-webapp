require 'rails_helper'
require 'spec_helper'

describe "Interacting with records from different quarters", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @q1            = FactoryGirl.create(:quarter,
                                       :inactive_and_deadlines_passed)
    @q2            = FactoryGirl.create(:quarter,
                                       :inactive_and_deadlines_passed,
                                       year: 2000)
    @q3            = FactoryGirl.create(:quarter,
                                       :inactive_and_deadlines_passed,
                                       year: 1999)
    @admin         = FactoryGirl.create(:admin)
    @advisor       = FactoryGirl.create(:advisor)
    @other_advisor = FactoryGirl.create(:advisor)
    @student       = FactoryGirl.create(:student)
    @other_student = FactoryGirl.create(:student)
  end

  context "when there are multiple quarters" do
    before(:each) do
      ldap_sign_in(@student)
      visit root_path
    end

    context "when there are no active quarters" do
      it "should not show any quarter tabs" do
        expect(page).to have_selector('.nav') do |nav|
          expect(nav).
            not_to contain(/#dropdown-\d{4}-[spring|summer|autumn|winter]/)
        end
      end
    end

    context "when there is one active quarter" do
      before do
        @q4 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "winter")
      end

      it "should show one quarter tab" do
        expect(page).to have_selector('.nav') do |nav|
          expect(nav).to contain(/#dropdown-2015-winter/)
        end
      end
    end

    context "when there are multiple active quarters" do
      before do
        @q4 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "winter")
        @q5 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "spring")
      end

      it "should show multiple quarter tabs" do
        expect(page).to have_selector('.nav') do |nav|
          expect(nav).to contain(/#dropdown-2015-winter/)
          expect(nav).to contain(/#dropdown-2015-spring/)
        end
      end
    end
  end

  context "when proposing a project" do
    before(:each) do
      ldap_sign_in(@advisor)
      visit root_path
    end

    context "when there are no active quarters" do
      it "should not be able to propose a project" do
        visit new_project_path
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        visit new_project_path(year: @q1.year, season: @q1.season)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        visit new_project_path(year: @q2.year, season: @q2.season)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        visit new_project_path(year: @q3.year, season: @q3.season)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        # Non-existent quarter
        visit new_project_path(year: 1000, season: "summer")
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    context "when there is an active quarter" do

      before do
        @q4 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "winter")
      end

      context "when proposing in an active quarter" do
        it "should let the advisor propose a project" do
          visit new_project_path(year: @q4.year, season: @q4.season)
          expect(current_path).to eq("/2015/winter/projects/new")
          # We test the rest of this in the new_project specs
        end
      end

      context "when directly proposing a project in an active quarter" do
        before do
          @proj = FactoryGirl.build(:project, advisor: @advisor,
                                    quarter: @q4,
                                    status: "pending",
                                    status_published: false,
                                    name: "abcdefghi",
                                    description: "a",
                                    expected_deliverables: "a",
                                    prerequisites: "a")
        end

        it "should be valid" do
          expect(@proj).to be_valid
        end
      end

      context "when directly proposing a project in an inactive quarter" do
        before do
          @proj = FactoryGirl.build(:project, advisor: @advisor,
                                    quarter: @q1,
                                    status: "pending",
                                    status_published: false,
                                    name: "abcdefghi",
                                    description: "a",
                                    expected_deliverables: "a",
                                    prerequisites: "a")
        end

        it "should be invalid" do
          expect(@proj).not_to be_valid
        end
      end

    end
  end

  context "when applying to a project" do

    before do
      @q4      = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                    :earlier_start_date, year: 2015,
                                    season: "winter")
      @p_new   = FactoryGirl.create(:project, :in_current_quarter,
                                    advisor: @advisor, status: "accepted",
                                    status_published: true)
      @p_old   = FactoryGirl.build(:project, quarter: @q1,
                                   advisor: @advisor, status: "accepted",
                                   status_published: true)
      @p_old.save(validate: false)
    end

    before(:each) do
      ldap_sign_in(@student)
      visit root_path
    end

    context "when applying in an active quarter" do
      it "should let the student apply" do
        visit q_path(@p_new, :new_project_submission)
        expect(current_path).to eq(q_path(@p_new, :new_project_submission))
        # We test the rest of this in the new_submission specs
      end
    end

    context "when applying to an old project (in an inactive quarter)" do
      # TODO: test applying by creating a record directly
      it "should not let the student apply" do # via redirection
        visit q_path(@p_old, :new_project_submission)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    context "when not applying in a quarter" do
      it "should not let the student apply" do
        visit new_project_submission_path(project_id: @p_new.id)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    context "when applying in the wrong quarter" do
      it "should not let the student apply" do
        visit new_project_submission_path(@p_new, year: 2005, season: "summer")
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    # Strange test, since we're not testing the quarter directly through the
    # submission -- only through the project it's attached to.
    context "when directly applying in an invalid quarter" do
      it "should be invalid" do
        @sub = FactoryGirl.build(:submission, student: @student,
                                 project: @p_old,
                                 status: "pending",
                                 status_approved: false,
                                 status_published: false)
        expect(@sub).not_to be_valid
      end
    end

    context "when directly applying in the valid quarter" do
      it "should be valid" do
        @sub = FactoryGirl.build(:submission, student: @student,
                                 project: @p_new,
                                 status: "pending",
                                 status_approved: false,
                                 status_published: false)
        expect(@sub).to be_valid
      end
    end

    # TODO: Viewing projects and submissions in the wrong quarters -> should redirect
  end

  context "when viewing projects" do

  end

  context "when viewing submissions" do

  end

  # viewing as an admin, as a student, etc...
end
