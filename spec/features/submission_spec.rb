require 'rails_helper'
require 'spec_helper'
require 'pry'

feature "Creating a new submission" do
  subject { page }

  before(:each) do
    @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
    @advisor = FactoryGirl.create(:advisor)
    @project = FactoryGirl.create(:project, :accepted_and_published,
                                  :in_current_quarter)
    @student = FactoryGirl.create(:student)

    #Rails.logger.debug("\n\nIs the project valid? #{@project.valid?}\n\n"*10)
    #Rails.logger.debug("\n\nIs the quarter valid? #{@quarter.valid?}\n\n"*10)
    #Rails.logger.debug("\n\nProject: #{@project.inspect}\n\n"*10)
    #Rails.logger.debug("\n\nQuarter: #{@quarter.inspect}\n\n"*10)

    # @student.save!
    sign_in(@student)
  end

  describe "new submission" do

    it "should have the Information field" do
      visit new_project_submission_url(@project.id)
      expect(page).to have_content("Interests")
    end

    it "should make our ActionMailer instance send the advisor an email" do
      visit new_project_submission_url(@project.id)
      #expect { click_button "Submit my application" }.to \
      #       change(ActionMailer::Base.deliveries, :count).by(1)
    end


  end

end
