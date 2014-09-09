require 'rails_helper'
require 'spec_helper'

describe "Creating a submission", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter    = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin      = FactoryGirl.create(:admin)
    @advisor    = FactoryGirl.create(:advisor)
    @student    = FactoryGirl.create(:student)
    @project    = FactoryGirl.create(:project, :accepted_and_published,
                                     :in_current_quarter, advisor: @advisor)
    ldap_sign_in(@student)
  end

  describe "the student viewing the project" do

    before(:each) do
      visit projects_path
    end

    it "should see the project on the projects page" do
      within("table") do
        expect(page).to have_content(@project.name)
      end
    end

    it "should see the project information on the project's page" do
      click_link(@project.name)
      # We're testing only the project's name...
      within("table") do
        expect(page).to have_content(@project.name)
      end
    end

    it "should see the project information on the project's page" do
      click_link(@project.name)
      expect(page).to have_content("apply")
    end

  end

  describe "the student filling out the new submission form" do
    before(:each) do
      visit new_project_submission_path(@project)
    end
  end


end
