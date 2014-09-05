require 'rails_helper'
require 'spec_helper'

feature "\"Signing in\" with LDAP" do
  # Make users signed in without signing them in.
  # See https://github.com/plataformatec/devise/wiki/
  # How-To:-Test-with-Capybara.
  Warden.test_mode!

  after(:each) { Warden.test_reset! }

  before(:each) do
    @student = FactoryGirl.create(:student)
    ldap_sign_in(@student)
  end

  describe "navigating to the home page" do
    # Confirm that the user is "signed in."
    it "should show my CNetID" do
      visit root_url
      expect(page).to have_content("#{@student.cnet}")
    end
  end

end
