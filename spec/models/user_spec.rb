require 'rails_helper'
require 'spec_helper'

RSpec.describe User, :type => :model do

  describe "user" do

    before(:each) do
      @user    = User.new(email: "test@university.edu",
                          password: "foobarfoo")
    end

    subject { @user }

    it { should respond_to(:email) }
    it { should respond_to(:projects) }
    it { should respond_to(:submissions) }
    it { should respond_to(:roles) }
    it { should respond_to(:formatted_roles) }
    it { should respond_to(:projects_applied_to) }
    it { should respond_to(:applied_to_projects?) }
    it { should respond_to(:applied_to_project?) }
    it { should respond_to(:made_project?) }
    it { should respond_to(:accepted_projects) }
    it { should respond_to(:pending_projects) }
    it { should respond_to(:projects_made_by_id) }
    it { should respond_to(:evaluated_submission?) }
    it { should respond_to(:formatted_affiliation) }
    it { should respond_to(:formatted_department) }
    it { should respond_to(:missing_proposal_info?) }

    it { should be_valid }

    it "should have an empty roles hash" do
      expect(@user.student).to be_truthy
      expect(@user.roles).to include "student"
      expect(@user.formatted_roles).to eq "student"
    end

    describe "projects" do
      before { @project = FactoryGirl.create(:project) }

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

    describe "with affiliation and department" do
      before do
        @advisor.update_attributes(affiliation: "Professor",
                                   department: "Computer Science")
      end

      it "should format them" do
        expect(@advisor.formatted_affiliation).to include("Professor")
        expect(@advisor.formatted_department).to include("Computer Science")
      end
    end

    describe "without affiliation or department" do
      before do
        @advisor.update_attributes(affiliation: "",
                                   department: "Computer Science")
      end

      it "should be missing information" do
        expect(@advisor.missing_proposal_info?).to be_truthy
        expect(@advisor.formatted_affiliation).to eq ""
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
