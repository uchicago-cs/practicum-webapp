require 'rails_helper'
require 'spec_helper'

RSpec.describe Submission, :type => :model do

  # Test whether submissions are (in)valid here

  describe "creating a submission" do
    describe "with invalid information" do
      it "should be invalid" do

      end
    end

    describe "with valid information" do
      it "should be valid" do

      end
    end

    describe "after the submission deadline" do

      before(:each) do
        @quarter = FactoryGirl.create(:quarter, :can_create_project,
                                      :cannot_create_submission,
                                      :earlier_start_date, :later_end_date)
        @admin   = FactoryGirl.create(:admin)
        @advisor = FactoryGirl.create(:advisor)
        @student = FactoryGirl.create(:student)
        @project = FactoryGirl.create(:project, :accepted_and_published,
                                      :in_current_quarter, advisor: @advisor)
      end

      it "should be invalid" do
        @submission = FactoryGirl.build(:submission, student: @student,
                                        project: @project,
                                        information: "a" * 500,
                                        qualifications: "a" * 500,
                                        courses: "a" * 500)
        expect(@submission).not_to be_valid
        expect(@submission.errors.values.flatten).
          to include("The application deadline has passed.")
      end
    end
  end
end
