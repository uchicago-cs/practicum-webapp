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

  # Things to test:
  # - When it can and cannot be done (not related to quarters, but to its
  # status)
  # - What it will look like to the advisor and to the admin (not to students
  # or other advisors, since the advisor can only edit the proposal before
  # others can see the project)
  # - Confirm that validations work upon editing (changing name, leaving
  # fields blank, making fields too short)
  # - Ensure that other advisors cannot edit the project

  # We do this just as the advisor rather than as both the advisor and the
  # admin.

  context "when the proposal is pending and unpublished" do
    context "editing the proposal with valid information" do
      before(:each) do
        ldap_sign_in(@advisor)
        visit project_path(@project)
        within("#content") { click_link "here" }
        fill_in "Name", with: "New title"
        fill_in "Description", with: "test " * 50
        fill_in "Related work", with: ""
        click_button "Edit my proposal"
      end

      context "as the advisor" do

        it "should be valid" do
          expect(current_path).to eq(project_path(@project))
          expect(page).to have_selector("div.alert.alert-success")
          expect(page).to have_content("Project proposal successfully " +
                                       "updated.")
        end

        it "should show the updated information" do
          within('tr', text: "Title") do
            expect(page).to have_content("New title")
          end

          within('tr', text: "Description") do
            expect(page).to have_content("test " * 50)
          end

          within('tr', text: "Related work") do
            expect(page).to have_content("N/A")
          end
        end

      end

    end
  end

end
