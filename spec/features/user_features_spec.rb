require 'rails_helper'
require 'spec_helper'

describe "Users viewing pages", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  context "viewing a guest user's profile" do
    context "while signed in" do
      before do
        @user_1 = FactoryGirl.build(:user)
        @user_2 = FactoryGirl.create(:guest)
        ldap_sign_in(@user_1)
      end

      # This isn't quite the behavior we want. Ideally, this should throw an
      # AR RecordNotFound error, because the guest user doesn't exist (it just
      # gets built in ability.rb).
      it "should not exist" do
        visit user_path(@user_2)
        # Similarly, we shouldn't expect this:
        expect(page).to have_content("Access denied")
        expect(current_path).to eq(root_path)
      end
    end
  end

  context "viewing user profiles" do
    context "not signed in" do
      before(:each) do
        @user_1 = FactoryGirl.create(:student)
      end

      it "should be asked to sign in or sign up" do
        visit user_path(@user_1)
        expect(page).to have_content("You need to sign in or sign up before " +
                                     "continuing.")
      end
    end

    context "signed in" do
      before(:each) do
        @user_1 = FactoryGirl.create(:student)
        @user_2 = FactoryGirl.create(:student)
        ldap_sign_in(@user_1)
      end

      context "viewing another user's profile" do
        it "should be redirected to the homepage" do
          visit user_path(@user_2)
          expect(page).to have_content("Access denied")
          expect(current_path).to eq(root_path)
        end
      end

      context "viewing one's own profile" do
        it "should see his / her account information" do
          visit user_path(@user_1)
          expect(page).to have_content(@user_1.first_name + " " +
                                       @user_1.last_name)
        end
      end
    end

  end

end
