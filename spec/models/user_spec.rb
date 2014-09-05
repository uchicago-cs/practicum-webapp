require 'rails_helper'
require 'spec_helper'

RSpec.describe User, :type => :model do

  describe "guest user" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    subject { @user }

    it { should respond_to(:email) }
    it { should respond_to(:projects) }
    it { should respond_to(:submissions) }
    it { should respond_to(:roles) }
    it { should respond_to(:projects_applied_to) }
    it { should respond_to(:applied_to_projects?) }
    it { should respond_to(:applied_to_project?) }
    it { should respond_to(:made_project?) }
    it { should respond_to(:accepted_projects) }
    it { should respond_to(:pending_projects) }
    it { should respond_to(:projects_made_by_id) }
    it { should respond_to(:evaluated_submission?) }
    it { should respond_to(:missing_proposal_info?) }

    it { should be_valid }

    it "should have an empty roles hash" do
      #expect(@user.student).to be_truthy
      #expect(@user.roles).to include "student"
      expect(formatted_roles(@user)).to eq ""
    end

    describe "projects" do
      before do
        @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
        @project = FactoryGirl.create(:project)
      end

      it "should not exist" do
        expect(@user.projects_applied_to).to be_empty
        expect(@user.applied_to_projects?).to be_falsey
        expect(@user.applied_to_project?(@project)).to be_falsey
        expect(@user.made_project?(@project)).to be_falsey
        expect(@user.accepted_projects).to be_empty
        expect(@user.pending_projects).to be_empty
        expect(@user.projects_made_by_id).to be_empty
      end
    end

    describe "who tries to propose a project" do
      it "should fail" do
        expect{FactoryGirl.create(:project, user: @user)}.to raise_error
      end
    end

    describe "who tries to create a submission" do
      before do
        @quarter = FactoryGirl.create(:quarter, :no_deadlines_passed)
        @project = FactoryGirl.create(:project)
      end
      it "should fail" do
        expect{FactoryGirl.create(:submission, project: @project,
                                  advisor: @user)}.to raise_error

        #Rails.logger.debug "#{FactoryGirl.create(:submission, project: @project, user: @user)}\n\n"*50
      end
    end

  end

  describe "student" do
    before(:each) do
      @student = FactoryGirl.create(:student)
    end

    describe "roles hash" do
      it "should contain 'student'" do
        expect(@student.roles).to include "student"
      end
    end
  end

  describe "advisor" do
    before(:each) do
      @advisor = FactoryGirl.create(:advisor)
    end

    describe "roles hash" do
      it "should contain 'advisor'" do
        expect(@advisor.roles).to include "advisor"
      end
    end

    context "with affiliation and department" do
      before do
        @advisor.update_attributes(affiliation: "Professor",
                                   department: "Computer Science")
      end

      it "should format them" do
        expect(formatted_affiliation(@advisor)).to include("Professor")
        expect(formatted_department(@advisor)).to include("Computer Science")
      end
    end

    context "without affiliation or department" do
      before do
        @advisor.update_attributes(affiliation: "",
                                   department: "Computer Science")
      end

      it "should be missing information" do
        expect(@advisor.missing_proposal_info?).to be_truthy
        expect(formatted_affiliation(@advisor)).to eq ""
      end
    end
  end

  describe "admin" do
    before(:each) do
      @admin   = FactoryGirl.create(:admin)
    end

    describe "roles hash" do
      it "should contain 'admin'" do
        expect(@admin.roles).to include "admin"
      end
    end
  end

end
