require 'rails_helper'
require 'spec_helper'
require 'pry'

feature "Creating a new submission" do
  subject { page }

  before(:each) do
    @advisor = User.create!(email: "advisor@school.edu",
                            advisor: true,
                            password: "foobarfoo",
                            password_confirmation: "foobarfoo")

    @project = @advisor.projects.create!(name: "project",
                                         deadline: DateTime.current,
                                         description: "b"*100,
                                         expected_deliverables: "b"*100,
                                         prerequisites: "b"*100,
                                         status: "accepted")

    @student = User.new(email: "student@school.edu",
                        student: true,
                        password: "foobarfoo",
                        password_confirmation: "foobarfoo")
    @student.save!
    sign_in(@student)
  end

  describe "new submission" do

    it "should have the Information field" do
      visit new_project_submission_url(@project.id)
      #save_and_open_page
      page.should have_content("Information")
    end

    it "should make our ActionMailer instance send the advisor an email" do
      visit new_project_submission_url(@project.id)
      expect { click_button "Submit my application" }.to \
             change(ActionMailer::Base.deliveries, :count).by(1)
    end


  end

end
