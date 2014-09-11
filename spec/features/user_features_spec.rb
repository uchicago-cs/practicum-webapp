require 'rails_helper'
require 'spec_helper'

describe "Users viewing pages", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before(:each) do
    @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
  end

  # Ideally, repeat this for students and advisors
  # (admins should be able to see everything).
  context "viewing a guest user's profile" do
    context "signed in" do
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
      context "as an admin" do
        before(:each) do
          @admin = FactoryGirl.create(:admin)
          @user = FactoryGirl.create(:user)
          ldap_sign_in(@admin)
        end

        context "viewing a user's profile" do
          it "should be accessible and show roles and affiliation + dept" do
            visit user_path(@user)
            expect(page).to have_content(@user.first_name + " " +
                                         @user.last_name)
            expect(page).to have_content("Roles")
            expect(page).to have_content("Affiliation and Department")
          end
        end
      end

      context "as a non-admin" do
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

  context "viewing the user index page" do
    before(:each) { 10.times { FactoryGirl.create(:user) } }

    context "as an admin" do
      before(:each) do
        @admin = FactoryGirl.create(:admin)
        ldap_sign_in(@admin)
      end

      it "should be able to visit the page and see the users" do
        visit users_path
        expect(current_path).to eq(users_path)
        User.all.each do |user|
          expect(page).to have_content(user.first_name)
          expect(page).to have_content(user.last_name)
        end
      end
    end

    # Repeat this for guests, users (?), students, and advisors.
    context "as a non-admin" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        ldap_sign_in(@user)
      end

      it "should be redirected to the homepage" do
        visit users_path
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
        expect(page).to have_content("Access denied")
      end
    end
  end

  # Set up the specs so they are grouped by:
  # admin: view pages
  # non-admin: view pages; get redirected with a flash message
  # Keep it DRY.

  context "as an admin" do
    before(:each) do
      @admin = FactoryGirl.create(:admin)
      ldap_sign_in(@admin)
    end

    context "viewing the pending projects page" do
      it "should show the appropriate information" do
        visit pending_projects_path
        expect(current_path).to eq pending_projects_path
        expect(page).to have_content("#{@quarter.season.capitalize} " +
                                     "#{@quarter.year} Pending Projects")
      end
    end

    context "viewing the quarters" do
      before(:each) { visit quarters_path }

      it "should bring the admin to the quarters page" do
        expect(current_path).to eq(quarters_path)
      end

      context "viewing the quarter index page" do
        it "should see a table rather than a list" do
          expect(page).to have_selector("table.table.table-bordered")
        end

        it "should see the quarters in the table" do
          Quarter.all.each do |quarter|
            expect(page).to have_content(quarter.season.capitalize)
            expect(page).to have_content(quarter.year)
            expect(page).to have_link("Edit", href: edit_quarter_path(quarter))
          end
        end

        it "should see the 'new quarter' link" do
          expect(page).to have_link("here", href: new_quarter_path)
        end
      end

      context "viewing the new quarter page" do
        before(:each) { within("#content") { click_link("here") } }

        it "should bring the admin to the 'new quarter' page" do
          expect(current_path).to eq(new_quarter_path)
          expect(page).to have_content("Create a Quarter")
        end
      end

      context "viewing the edit quarter page" do
        # `@quarter` is the only quarter we created.
        before(:each) { click_link("Edit") }

        it "should bring the admin to the 'edit quarter' page" do
          expect(current_path).to eq(edit_quarter_path(@quarter))
          expect(page).to have_content("Edit #{@quarter.season.capitalize} " +
                                       "#{@quarter.year}")
        end
      end
    end
  end

  context "as a non-admin user" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      ldap_sign_in(@user)
    end

    context "visiting the quarters page" do
      before(:each) { visit quarters_path }

      it "should show the quarters page with a list rather than a table" do
        expect(current_path).to eq(quarters_path)
        expect(page).to have_content(@quarter.season.capitalize)
        expect(page).to have_content(@quarter.year)
        expect(page).not_to have_selector("table")
      end

      it "should not be able to see the edit and new links" do
        expect(page).
          not_to have_css("a[href~='#{edit_quarter_path(@quarter)}'")
        expect(page).
          not_to have_css("a[href~='#{new_quarter_path}'")
      end
    end
  end
end
