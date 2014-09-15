require 'rails_helper'
require 'spec_helper'

describe "Editing a project's information", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter    = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @admin      = FactoryGirl.create(:admin)
    @advisor    = FactoryGirl.create(:advisor)
    @student    = FactoryGirl.create(:student)
    @project    = FactoryGirl.create(:project, :in_current_quarter,
                                     advisor: @advisor, status: "pending",
                                     status_published: false)
  end

  # - When it can and cannot be done (not related to quarters, but related to
  # its status)
  # - What it will look like to the advisor and to the admin

  context "editing the proposal" do

  end

end
