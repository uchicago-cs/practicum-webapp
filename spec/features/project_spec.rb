require 'rails_helper'
require 'spec_helper'

feature "Creating a project" do
  subject { page }

  context "before the deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      sign_in(@advisor)
      click_link("Propose a project")
    end

    describe "new project" do

      it "should have the 'new proposal' text" do
        expect(page).to have_content("new project proposal")
      end

      describe "with valid input" do
        it "should create successfully" do
          fill_in "Name", with: "Generic Project Name"
          fill_in "Description", with: "a"*500
          fill_in "Expected deliverables", with: "a"*500
          fill_in "Prerequisites", with: "a"*500
          expect{ click_button "Create my proposal" }.to \
            change{ Project.count }.by(1)

          @project = Project.order('created_at DESC').first
          expect(@project.status).to eq "pending"
          expect(@project.status_published).to eq false
        end
      end

      describe "with invalid input" do
        it "should not create successfully" do
          FactoryGirl.create(:project, :in_current_quarter, \
                             name: "Generic Project Name")
          fill_in "Name", with: "Generic Project Name"
          fill_in "Description", with: "a"*500
          fill_in "Expected deliverables", with: "a"*500
          fill_in "Prerequisites", with: "a"*500
          expect{ click_button "Create my proposal" }.to \
            change{ Project.count }.by(0)
          expect(page).to have_selector('div.alert.alert-error')
        end
      end

    end

  end

  context "after the deadline" do

    before(:each) do
      @quarter = FactoryGirl.create(:quarter, :all_deadlines_passed)
      @advisor = FactoryGirl.create(:advisor)
      sign_in(@advisor)
    end
  end

end
