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
                                     advisor: @advisor)
    ldap_sign_in(@student)
  end

  describe "the student filling out the form" do

    before(:each) do
      visit projects_path
      save_and_open_page
    end

    it "should see the project on the projects page"
    # visit new_project_submission_path(@project)


  end


end
