require 'rails_helper'
require 'spec_helper'

feature "\"Signing in\" with LDAP" do

  before(:each) do
    @student = FactoryGirl.create(:student)

    sign_in(@student, :no_capybara)
  end

  describe "navigate to the home page" do
    it "should show my CNetID" do
      visit root_url
      expect(page).to have_content("#{@student.cnet}")
    end
  end

end
