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
  end

  context "as a non-advisor" do

    before(:each) { ldap_sign_in(@user) }

    context "having done so before" do

      it "should redirect to the homepage" do

      end

    end

    context "not having done so before" do

      it "should render the page and button" do

      end

      context "clicking the button" do

        it "should change the user's advisor_status_pending boolean" do

        end

        it "should redirect the user to the homepage" do

        end

        it "should show the advisor_status_pending message on every page" do

        end

      end

      context "when their request is approved" do

        # Do this as an admin.
        # Then, sign in as the student.

        it "should make the user an advisor" do

        end

        it "should remove the message that appeared on every page" do

        end

      end

    end

  end

  context "as an advisor" do

    before(:each) { ldap_sign_in(@advisor) }

    it "should redirect to the homepage" do

    end

  end

end
