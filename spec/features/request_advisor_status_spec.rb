require 'rails_helper'
require 'spec_helper'

describe "Requesting advisor status", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @user    = FactoryGirl.create(:user)
    @advisor = FactoryGirl.create(:advisor)
    @admin   = FactoryGirl.create(:admin)
  end

  context "as a non-advisor" do

    before(:each) { ldap_sign_in(@user) }

    context "having done so before" do

      before(:each) { @user.update_attributes(advisor_status_pending: true) }

      it "should redirect to the homepage" do
        visit request_advisor_access_path
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
        expect(page).to have_content("You have already requested advisor " +
                                     "privileges")
      end

    end

    context "not having done so before" do

      before(:each) { visit request_advisor_access_path }

      it "should render the page and button" do
        expect(current_path).to eq(request_advisor_access_path)
        expect(page).to have_content("Request Advisor Privileges")
        # We expect to see a button, but we use #link_to in the view.
        expect(page).to have_link("Submit request")
      end

      context "clicking the button" do

        it "should change the user's advisor_status_pending boolean" do
          # Again, we /appear/ to be clicking a button.
          expect{ click_link "Submit request" }.
            to change{ @user.reload.advisor_status_pending }.from(false).
            to(true)
        end

        it "should redirect the user to the homepage" do
          click_link "Submit request"
          expect(current_path).to eq(root_path)
        end

        it "should show the temporary 'your request has been sent' message" do
          click_link "Submit request"
          expect(page).to have_selector("div.alert.alert-success")
          expect(page).to have_content("You have requested advisor privileges")
        end

        it "should show the advisor_status_pending message on every page" do
          click_link "Submit request"
          expect(page).to have_selector("div.alert.alert-info")
          expect(page).to have_content("pending approval by an administrator")
          # Visit an arbitrary page to test for the presence of the message.
          visit projects_path
          expect(page).to have_selector("div.alert.alert-info")
          expect(page).to have_content("pending approval by an administrator")
          # It won't have the temporary message, though.
          expect(page).not_to have_selector("div.alert.alert-success")
        end

      end

      context "when their request is approved" do

        before(:each) do
          logout
          ldap_sign_in(@admin)
          visit user_path(@user)
          check "Advisor"
          click_button "Change this user's roles"
        end

        it "should make the user an advisor" do
          expect(@user.reload.advisor).to eq(true)
        end

        it "should turn off the user's 'advisor status pending' status" do
          expect(@user.reload.advisor_status_pending).to eq(false)
        end

        context "and they are signed in" do

          before(:each) do
            logout
            ldap_sign_in(@user)
          end

          it "should remove the message that appeared on every page" do
            visit root_url
            expect(page).not_to have_selector("div.alert.alert-info")
            expect(page).not_to have_content("pending approval by an admin")
          end

        end

      end

    end

  end

  context "as an advisor" do

    before(:each) { ldap_sign_in(@advisor) }

    it "should redirect to the homepage" do
      visit request_advisor_access_path
      expect(current_path).to eq(root_path)
      expect(page).to have_selector("div.alert.alert-danger")
      expect(page).to have_content("You are already an advisor")
    end

  end

end
