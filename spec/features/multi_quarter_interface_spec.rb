require 'rails_helper'
require 'spec_helper'

describe "Editing a project's information", type: :feature do
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
      end
    end

    context "when there is an active quarter" do

      context "when proposing in an active quarter" do

      end

      context "when proposing in an inactive quarter" do

      end

    end
  end

  context "when applying to a project" do
    before(:each) do
      ldap_sign_in(@student)
      visit root_path
    end

    context "when there are no active quarters" do

    end

    context "when there is an active quarter" do

      context "when applying in an active quarter" do

      end

      context "when applying in an inactive quarter" do

      end

    end
  end
end
