require 'rails_helper'
require 'spec_helper'

feature "\"Signing in\" with LDAP" do
  include Warden::Test::Helpers
  Warden.test_mode!

  before(:each) do
    @student = FactoryGirl.create(:student)

    login_as(@student, scope: :user)
  end

  after(:each) { Warden.test_reset! }

  describe "navigating to the home page" do
    it "should show my CNetID" do
      visit root_url
      expect(page).to have_content("#{@student.cnet}")
    end
  end

end
