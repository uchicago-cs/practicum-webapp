require 'rails_helper'
require 'spec_helper'

# Project proposal form?
describe "Filling out a form", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  context "after the deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :all_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      ldap_sign_in(@advisor)
      visit root_url
    end

    describe "clicking the proposal creation link" do

      it "should redirect the user to the home page" do
        visit new_project_url
        expect(current_path).to eq root_path
        expect(page).to have_selector('div.alert')
        expect(page).to have_content("Welcome to the MPCS Practicum")
      end
    end

  end

  # context "before the deadline" do

  #   before(:each) do
  #     @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
  #     @advisor = FactoryGirl.create(:advisor)
  #     ldap_sign_in(@advisor)
  #     visit new_project_url
  #   end

  #   describe "new project" do

  #     describe "with invalid input" do

  #       it "should not create when one of its fields is too short" do
  #         fill_in "project_name", with: "stff"
  #         fill_in "Description", with: "a"*99
  #         fill_in "Expected deliverables", with: "a"*100
  #         fill_in "Prerequisites", with: "a"*100
  #         expect{ click_button "Create my proposal" }.
  #           to change{ Project.count }.by(0)
  #         expect(page).to have_selector('div.alert.alert-danger')
  #       end

  #       it "should not create when project with its name exists" do
  #         FactoryGirl.create(:project, :in_current_quarter,
  #                            name: "Generic Project Name")
  #         fill_in "project_name", with: "Generic Project Name"
  #         fill_in "Description", with: "a"*500
  #         fill_in "Expected deliverables", with: "a"*500
  #         fill_in "Prerequisites", with: "a"*500
  #         expect{ click_button "Create my proposal" }.
  #           to change{ Project.count }.by(0)
  #         expect(page).to have_selector('div.alert.alert-danger')
  #       end
  #     end

  #     describe "with valid input" do
  #       it "should create successfully" do
  #         Rails.logger.debug page.body * 5
  #         puts page.body * 5
  #         fill_in "project_name", with: "stuff"
  #         fill_in "Description", with: "a"*500
  #         fill_in "Expected deliverables", with: "a"*500
  #         fill_in "Prerequisites", with: "a"*500
  #         expect{ click_button "Create my proposal" }.
  #           to change{ Project.count }.by(1)

  #         @project = Project.order('created_at DESC').first
  #         expect(@project.status).to eq "pending"
  #         expect(@project.status_published).to eq false
  #       end
  #     end
  #   end
  # end
end
