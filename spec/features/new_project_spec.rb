require 'rails_helper'
require 'spec_helper'

describe "Creating a project", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  context "before the deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      ldap_sign_in(@advisor)
      visit new_project_url
    end

    describe "new project" do

      it "should have the h2 text" do
        expect(page).to have_content("Propose a Project")
      end

      describe "with valid input" do
        it "should create successfully" do
          fill_in "Title", with: "Generic Project Name"
          fill_in "Description", with: "a"*500
          fill_in "Expected deliverables", with: "a"*500
          fill_in "Prerequisites", with: "a"*500
          expect{ click_button "Create my proposal" }.
            to change{ Project.count }.by(1)

          @project = Project.order('created_at DESC').first
          expect(@project.status).to eq "pending"
          expect(@project.status_published).to eq false
        end
      end

      describe "with invalid input" do
        it "should not create when project with its name exists" do
          FactoryGirl.create(:project, :in_current_quarter,
                             name: "Generic Project Name")
          fill_in "Title", with: "Generic Project Name"
          fill_in "Description", with: "a"*500
          fill_in "Expected deliverables", with: "a"*500
          fill_in "Prerequisites", with: "a"*500
          expect{ click_button "Create my proposal" }.
            to change{ Project.count }.by(0)
          expect(page).to have_selector('div.alert.alert-danger')
        end

        it "should not create when one of its fields is too short" do
          fill_in "Title", with: "Generic Project Name"
          fill_in "Description", with: "a"*99
          fill_in "Expected deliverables", with: "a"*100
          fill_in "Prerequisites", with: "a"*100
          expect{ click_button "Create my proposal" }.
            to change{ Project.count }.by(0)
          expect(page).to have_selector('div.alert.alert-danger')
        end
      end

    end

  end

  context "after the deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :all_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      ldap_sign_in(@advisor)
      visit root_url
    end

    describe "clicking the proposal creation link" do

      it "should redirect the user to the home page" do
        visit new_project_url
        expect(page).to have_selector('div.alert')
        expect(page).to have_content("About the Practicum Program")
      end
    end

    # describe "creating a project with valid input" do
    #   it "should not create" do
    #   end
    # end
  end

end
