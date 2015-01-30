require 'rails_helper'
require 'spec_helper'

describe "Interacting with records from different quarters", type: :feature do
  Warden.test_mode!

  subject { page }

  after(:each) { Warden.test_reset! }

  before do
    @q1            = FactoryGirl.create(:quarter,
                                        :inactive_and_deadlines_passed,
                                        year: 2001,
                                        season: "winter")
    @q2            = FactoryGirl.create(:quarter,
                                       :inactive_and_deadlines_passed,
                                       year: 2000)
    @q3            = FactoryGirl.create(:quarter,
                                       :inactive_and_deadlines_passed,
                                       year: 1999)
    @admin         = FactoryGirl.create(:admin)
    @advisor       = FactoryGirl.create(:advisor)
    @other_advisor = FactoryGirl.create(:advisor)
    @student       = FactoryGirl.create(:student)
    @other_student = FactoryGirl.create(:student)
  end

  context "when there are multiple quarters" do

    before do
      ldap_sign_in(@student)
      visit root_path
    end

    context "when there are no active quarters" do
      it "should not show any quarter tabs" do
        expect(page).to have_selector('.nav') do |nav|
          expect(nav).
            not_to contain(/#dropdown-\d{4}-[spring|summer|autumn|winter]/)
        end
      end
    end

    context "when there is one active quarter" do
      before(:each) do
        @q4 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "winter")
      end

      it "should show one quarter tab" do
        expect(page).to have_selector('.nav') do |nav|
          expect(nav).to contain(/#dropdown-2015-winter/)
        end
      end
    end

    context "when there are multiple active quarters" do
      before(:each) do
        @q4 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "winter")
        @q5 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "spring")
      end

      it "should show multiple quarter tabs" do
        expect(page).to have_selector('.nav') do |nav|
          expect(nav).to contain(/#dropdown-2015-winter/)
          expect(nav).to contain(/#dropdown-2015-spring/)
        end
      end
    end
  end

  context "when proposing a project" do
    before(:each) do
      ldap_sign_in(@advisor)
      visit root_path
    end

    context "when there are no active quarters" do
      it "should not be able to propose a project" do
        visit new_project_path
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        visit new_project_path(year: @q1.year, season: @q1.season)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        visit new_project_path(year: @q2.year, season: @q2.season)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        visit new_project_path(year: @q3.year, season: @q3.season)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")

        # Non-existent quarter
        visit new_project_path(year: 1000, season: "summer")
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    context "when there is an active quarter" do

      before do
        @q4 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                 :earlier_start_date, year: 2015,
                                 season: "winter")
      end

      context "when proposing in an active quarter" do
        it "should let the advisor propose a project" do
          visit new_project_path(year: @q4.year, season: @q4.season)
          expect(current_path).to eq("/2015/winter/projects/new")
          # We test the rest of this in the new_project specs
        end
      end

      context "when directly proposing a project in an active quarter" do
        before do
          @proj = FactoryGirl.build(:project, advisor: @advisor,
                                    quarter: @q4,
                                    status: "pending",
                                    status_published: false,
                                    name: "abcdefghi",
                                    description: "a",
                                    expected_deliverables: "a",
                                    prerequisites: "a")
        end

        it "should be valid" do
          expect(@proj).to be_valid
        end
      end

      context "when directly proposing a project in an inactive quarter" do
        before do
          @proj = FactoryGirl.build(:project, advisor: @advisor,
                                    quarter: @q1,
                                    status: "pending",
                                    status_published: false,
                                    name: "abcdefghi",
                                    description: "a",
                                    expected_deliverables: "a",
                                    prerequisites: "a")
        end

        it "should be invalid" do
          expect(@proj).not_to be_valid
        end
      end

    end
  end

  context "when applying to a project" do

    before do
      @q4      = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                    :earlier_start_date, year: 2015,
                                    season: "winter")
      @p_new   = FactoryGirl.create(:project, :in_active_quarter,
                                    advisor: @advisor, status: "accepted",
                                    status_published: true)
      @p_old   = FactoryGirl.build(:project, quarter: @q1,
                                   advisor: @advisor, status: "accepted",
                                   status_published: true)
      @p_old.save(validate: false)

      ldap_sign_in(@student)
      visit root_path
    end

    context "when applying in an active quarter" do
      it "should let the student apply" do
        visit q_path(@p_new, :new_project_submission)
        expect(current_path).to eq(q_path(@p_new, :new_project_submission))
        # We test the rest of this in the new_submission specs
      end
    end

    context "when applying to an old project (in an inactive quarter)" do
      # TODO: test applying by creating a record directly
      it "should not let the student apply" do # via redirection
        visit q_path(@p_old, :new_project_submission)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    context "when not applying in a quarter" do
      it "should not let the student apply" do
        visit new_project_submission_path(project_id: @p_new.id)
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    context "when applying in the wrong quarter" do
      it "should not let the student apply" do
        visit new_project_submission_path(@p_new, year: 2005, season: "summer")
        expect(current_path).to eq(root_path)
        expect(page).to have_selector("div.alert.alert-danger")
      end
    end

    # Strange test, since we're not testing the quarter directly through the
    # submission -- only through the project it's attached to.
    context "when directly applying in an invalid quarter" do
      it "should be invalid" do
        @sub = FactoryGirl.build(:submission, student: @student,
                                 project: @p_old,
                                 status: "pending",
                                 status_approved: false,
                                 status_published: false)
        expect(@sub).not_to be_valid
      end
    end

    context "when directly applying in the valid quarter" do
      it "should be valid" do
        @sub = FactoryGirl.build(:submission, student: @student,
                                 project: @p_new,
                                 status: "pending",
                                 status_approved: false,
                                 status_published: false)
        expect(@sub).to be_valid
      end
    end

    # TODO: Viewing projects and submissions in the wrong quarters -> should redirect
  end

  context "when viewing projects" do
    before do
      @q4    = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                    :earlier_start_date, year: 2015,
                                    season: "winter")
      @p_new = FactoryGirl.create(:project, quarter: @q4,
                                    advisor: @advisor, status: "accepted",
                                    status_published: true)
      @p_old = FactoryGirl.build(:project, quarter: @q1,
                                   advisor: @advisor, status: "accepted",
                                   status_published: true)
      @p_old.save(validate: false)

      # We don't need to sign in since the projects are public.
      #before(:each) { ldap_sign_in(@student) }
    end

    context "viewing an old project in the right quarter" do
      it "should be valid" do
        visit q_path(@p_old)
        expect(current_path).to eq(q_path(@p_old))
      end
    end

    context "viewing a new project in the right quarter" do
      it "should be valid" do
        visit q_path(@p_new)
        expect(current_path).to eq(q_path(@p_new))
      end
    end

    context "viewing a project at a path in an invalid quarter" do
      it "should redirect to the path with the right quarter" do
        visit project_path(@p_new, year: @q3.year, season: @q3.season)
        expect(current_path).to eq(q_path(@p_new))
      end
    end
  end

  context "when viewing submissions" do
    before do
      @q4    = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                  :earlier_start_date, year: 2015,
                                  season: "winter")
      @p_new = FactoryGirl.create(:project, quarter: @q4,
                                  advisor: @advisor, status: "accepted",
                                  status_published: true)
      @sub   = FactoryGirl.create(:submission, student: @student,
                                  project: @p_new,
                                  status: "accepted",
                                  status_approved: true,
                                  status_published: true)
      ldap_sign_in(@student)
    end

    context "viewing a submission with a path in the valid quarter" do
      it "should be valid" do
        visit q_path(@sub)
        expect(current_path).to eq(q_path(@sub))
      end
    end

    context "viewing a submission with a path in an invalid quarter" do
      it "should redirect to the path with the right quarter" do
        visit submission_path(@sub, year: @q3.year, season: @q3.season)
        expect(current_path).to eq(q_path(@sub))
      end
    end
  end

  context "when viewing evaluations" do
    before do
      @q4       = FactoryGirl.create(:quarter, :no_deadlines_passed,
                                     :earlier_start_date, year: 2015,
                                     season: "winter")
      @p_new    = FactoryGirl.create(:project, quarter: @q4,
                                     advisor: @advisor, status: "accepted",
                                     status_published: true)
      @sub      = FactoryGirl.create(:submission, student: @student,
                                     project: @p_new,
                                     status: "accepted",
                                     status_approved: true,
                                     status_published: true)
      @template = FactoryGirl.create(:evaluation_template, quarter: @q4,
                                     start_date: DateTime.current - 1.day,
                                     end_date: DateTime.current + 1.day,
                                     name: "Midterm",
                                     active: true)
      @eval     = FactoryGirl.create(:evaluation, submission: @sub,
                                     advisor_id: @advisor.id,
                                     student_id: @student.id,
                                     project_id: @p_new.id,
                                     evaluation_template_id: @template.id)
      ldap_sign_in(@advisor)
    end

    context "viewing an evaluation with a path in the valid quarter" do
      it "should be valid" do
        visit q_path(@eval)
        expect(current_path).to eq(q_path(@eval))
        expect(page).to have_content(@p_new.name)
      end
    end

    context "viewing an evaluation with a path without a quarter" do
      it "should redirect to the path with the valid quarter" do
        visit evaluation_path(@eval, year: nil, season: nil)
        expect(current_path).to eq(q_path(@eval))
        expect(page).not_to have_selector("div.alert.alert-danger")
      end
    end

    context "viewing an evaluation with a path in an invalid quarter" do
      it "should redirect to the path with the valid quarter" do
        visit evaluation_path(@eval, year: @q3.year, season: @q3.season)
        expect(current_path).to eq(q_path(@eval))
        expect(page).not_to have_selector("div.alert.alert-danger")
      end
    end

    # TODO: Global evaluations path (remove?)
  end

  context "viewing projects, submissions, and evaluations pages" do
    before do
      @q4 = FactoryGirl.create(:quarter, :no_deadlines_passed,
                               :earlier_start_date, year: 2015,
                               season: "winter")
      @q5 = FactoryGirl.create(:quarter, start_date: DateTime.now + 1.year,
                               year: 2016,
                               season: "winter")
      @q5.update_column(:start_date, DateTime.yesterday)
      @q5.update_column(:project_proposal_deadline, DateTime.now - 5.hours)

      @p1 = FactoryGirl.build(:project, quarter: @q1,
                               advisor: @advisor, status: "accepted",
                               status_published: true)
      @p2 = FactoryGirl.build(:project, quarter: @q2,
                               advisor: @advisor, status: "accepted",
                               status_published: true)
      @p3 = FactoryGirl.build(:project, quarter: @q3,
                               advisor: @advisor, status: "accepted",
                               status_published: true)
      @p4 = FactoryGirl.build(:project, quarter: @q4,
                               advisor: @advisor, status: "accepted",
                               status_published: true)
      @p5 = FactoryGirl.build(:project, quarter: @q5,
                               advisor: @advisor, status: "accepted",
                              status_published: true)
      @p1.save(validate: false)
      @p2.save(validate: false)
      @p3.save(validate: false)
      @p4.save(validate: false)
      @p5.save(validate: false)

      @s1 = FactoryGirl.build(:submission, student: @student, project: @p1,
                              status: "accepted", status_approved: true,
                              status_published: true)
      @s2 = FactoryGirl.build(:submission, student: @student, project: @p2,
                              status: "accepted", status_approved: true,
                              status_published: true)
      @s3 = FactoryGirl.build(:submission, student: @student, project: @p3,
                              status: "accepted", status_approved: true,
                              status_published: true)
      @s4 = FactoryGirl.build(:submission, student: @student, project: @p4,
                              status: "accepted", status_approved: true,
                              status_published: true)
      @s5 = FactoryGirl.build(:submission, student: @student, project: @p5,
                              status: "accepted", status_approved: true,
                              status_published: true)
      # Note: these submisions do not have to be accepted, approved, and
      # published for these specs to pass.
      @s1.save(validate: false)
      @s2.save(validate: false)
      @s3.save(validate: false)
      @s4.save(validate: false)
      @s5.save(validate: false)
    end

    context "on the global projects page" do
      it "should show projects in the active and future quarters" do
        visit projects_path
        expect(page).not_to have_content(@p1.name)
        expect(page).not_to have_content(@p2.name)
        expect(page).not_to have_content(@p3.name)
        expect(page).to have_content(@p4.name)
        expect(page).to have_content(@p5.name)
      end
    end

    context "on quarter-specific projects pages" do
      it "should show the projects in the respective quarters" do
        visit projects_path(year: @q1.year, season: @q1.season)
        expect(page).to have_content(@p1.name)
        # We expect to see two table rows: the head row and the only proj row.
        expect(page).to have_selector("table tr", maximum: 2)

        visit projects_path(year: @q2.year, season: @q2.season)
        expect(page).to have_content(@p2.name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit projects_path(year: @q3.year, season: @q3.season)
        expect(page).to have_content(@p3.name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit projects_path(year: @q4.year, season: @q4.season)
        expect(page).to have_content(@p4.name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit projects_path(year: @q5.year, season: @q5.season)
        expect(page).to have_content(@p5.name)
        expect(page).to have_selector("table tr", maximum: 2)
      end
    end

    context "on submissions pages" do
      before { ldap_sign_in(@admin) }

      # Note: there is no global submissions page.

      context "on quarter-specific submissions pages" do
        it "should show the submissions in the respective quarters" do
          visit submissions_path(year: @q1.year, season: @q1.season)
          expect(page).to have_content(@s1.project.name)
          expect(page).to have_selector("table tr", maximum: 2)

          visit submissions_path(year: @q2.year, season: @q2.season)
          expect(page).to have_content(@s2.project.name)
          expect(page).to have_selector("table tr", maximum: 2)

          visit submissions_path(year: @q3.year, season: @q3.season)
          expect(page).to have_content(@s3.project.name)
          expect(page).to have_selector("table tr", maximum: 2)

          visit submissions_path(year: @q4.year, season: @q4.season)
          expect(page).to have_content(@s4.project.name)
          expect(page).to have_selector("table tr", maximum: 2)

          visit submissions_path(year: @q5.year, season: @q5.season)
          expect(page).to have_content(@s5.project.name)
          expect(page).to have_selector("table tr", maximum: 2)
        end
      end
    end

    context "on evaluations pages" do
      before do
        @template = FactoryGirl.create(:evaluation_template, quarter: @q4,
                                       start_date: DateTime.current - 1.day,
                                       end_date: DateTime.current + 1.day,
                                       name: "Midterm",
                                       active: true)
        @e1     = FactoryGirl.create(:evaluation, submission: @s1,
                                    advisor_id: @advisor.id,
                                    student_id: @student.id,
                                    project_id: @p1.id,
                                    evaluation_template_id: @template.id)
        @e2     = FactoryGirl.create(:evaluation, submission: @s2,
                                    advisor_id: @advisor.id,
                                    student_id: @student.id,
                                    project_id: @p2.id,
                                    evaluation_template_id: @template.id)
        @e3     = FactoryGirl.create(:evaluation, submission: @s3,
                                    advisor_id: @advisor.id,
                                    student_id: @student.id,
                                    project_id: @p3.id,
                                    evaluation_template_id: @template.id)
        @e4     = FactoryGirl.create(:evaluation, submission: @s4,
                                    advisor_id: @advisor.id,
                                    student_id: @student.id,
                                    project_id: @p4.id,
                                    evaluation_template_id: @template.id)
        @e5     = FactoryGirl.create(:evaluation, submission: @s5,
                                    advisor_id: @advisor.id,
                                    student_id: @student.id,
                                    project_id: @p5.id,
                                    evaluation_template: @template)
        ldap_sign_in(@admin)
      end

      context "on the global evaluations page" do
        # redirect or invalid path?
      end

      context "on quarter-specific evaluations pages" do
        it "should show the projects in the respective quarters" do
          visit evaluations_path(year: @q1.year, season: @q1.season)
          expect(page).to have_content(@p1.name)
          expect(page).to have_selector("table tr", maximum: 2)
          visit evaluations_path(year: @q2.year, season: @q2.season)
          expect(page).to have_content(@p2.name)
          expect(page).to have_selector("table tr", maximum: 2)
          visit evaluations_path(year: @q3.year, season: @q3.season)
          expect(page).to have_content(@p3.name)
          expect(page).to have_selector("table tr", maximum: 2)
          visit evaluations_path(year: @q4.year, season: @q4.season)
          expect(page).to have_content(@p4.name)
          expect(page).to have_selector("table tr", maximum: 2)
          visit evaluations_path(year: @q5.year, season: @q5.season)
          expect(page).to have_content(@p5.name)
          expect(page).to have_selector("table tr", maximum: 2)
        end
      end
    end
  end

  context "viewing quarter-specific pages" do
    before do
      @p_1 = FactoryGirl.build(:project, advisor: @advisor,
                               quarter: @q1,
                               status: "pending",
                               status_published: false,
                               name: "abcdefghi",
                               description: "a",
                               expected_deliverables: "n",
                               prerequisites: "n")
      @p_2 = FactoryGirl.build(:project, advisor: @advisor,
                               quarter: @q2,
                               status: "pending",
                               status_published: false,
                               name: "jklmnop",
                               description: "n",
                               expected_deliverables: "a",
                               prerequisites: "n")
      @p_1.save(validate: false)
      @p_2.save(validate: false)

      @s_1 = FactoryGirl.build(:submission, student: @student, project: @p_1,
                               status: "draft", status_approved: false,
                               status_published: false)
      @s_2 = FactoryGirl.build(:submission, student: @student,
                               project: @p_2, status: "draft",
                               status_approved: false, status_published: false)
      @s_3 = FactoryGirl.build(:submission, student: @other_student,
                               project: @p_2, status: "accepted",
                               status_approved: true, status_published: true)
      @s_1.save(validate: false)
      @s_2.save(validate: false)
      @s_3.save(validate: false)
    end


    context "when viewing pending projects" do

      context "as an admin" do
        before { ldap_sign_in(@admin) }
        context "in specific quarters" do
          it "should show the right projects on the right pages" do
            visit pending_projects_path(year: @q1.year, season: @q1.season)
            expect(page).to have_content(@p_1.name)
            expect(page).not_to have_content(@p_2.name)
            expect(page).to have_selector("table tr", maximum: 2)

            visit pending_projects_path(year: @q2.year, season: @q2.season)
            expect(page).to have_content(@p_2.name)
            expect(page).not_to have_content(@p_1.name)
            expect(page).to have_selector("table tr", maximum: 2)
          end
        end

        context "on the global 'pending projects' page" do
          it "should redirect to the homepage" do
            visit pending_projects_path
            expect(current_path).to eq(root_path)
            expect(page).to have_selector("div.alert.alert-danger")
          end
        end
      end
    end

    context "when viewing submission drafts" do

      context "in a specific quarter" do
        context "as an admin" do
          before { ldap_sign_in(@admin) }
          it "should show the right submission drafts on the right pages" do
            visit submission_drafts_path(year: @q1.year, season: @q1.season)
            expect(page).to have_content(@s_1.project.name)
            expect(page).not_to have_content(@s_2.project.name)
            expect(page).to have_selector("table tr", maximum: 2)

            visit submission_drafts_path(year: @q2.year, season: @q2.season)
            expect(page).to have_content(@s_2.project.name)
            expect(page).not_to have_content(@s_1.project.name)
            expect(page).to have_selector("table tr", maximum: 2)
          end
        end
      end
    end

    context "visiting an advisor's my_projects page in different quarters" do
      before { ldap_sign_in(@advisor) }

      it "should show the right projects on the right pages" do
        visit(users_projects_path(year: @q1.year, season: @q1.season))
        expect(current_path).to eq(users_projects_path(year: @q1.year,
                                                       season: @q1.season))
        expect(page).to have_content(@p_1.name)
        expect(page).not_to have_content(@p_2.name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit(users_projects_path(year: @q2.year, season: @q2.season))
        expect(current_path).to eq(users_projects_path(year: @q2.year,
                                                       season: @q2.season))
        expect(page).to have_content(@p_2.name)
        expect(page).not_to have_content(@p_1.name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit (users_projects_all_path(@advisor))
        expect(page).to have_content(@p_1.name)
        expect(page).to have_content(@p_2.name)
        expect(page).to have_selector("table tr", maximum: 3)
      end
    end

    context "visiting a student's my_submissions page in different quarters" do
      before { ldap_sign_in(@student) }

      it "should show the right submissions on the right pages" do
        visit(users_submissions_path(year: @q1.year, season: @q1.season))
        expect(current_path).to eq(users_submissions_path(year: @q1.year,
                                                          season: @q1.season))
        expect(page).to have_content(@s_1.project.name)
        expect(page).not_to have_content(@s_2.project.name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit(users_submissions_path(year: @q2.year, season: @q2.season))
        expect(current_path).to eq(users_submissions_path(year: @q2.year,
                                                          season: @q2.season))
        expect(page).to have_content(@s_2.project.name)
        expect(page).not_to have_content(@s_1.project.name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit (users_submissions_all_path(@student))
        expect(page).to have_content(@s_1.project.name)
        expect(page).to have_content(@s_2.project.name)
        expect(page).to have_selector("table tr", maximum: 3)
      end
    end

    context "visiting an advisor's my_students page in different quarters" do
      before do
        ldap_sign_in(@advisor)

        @s_1.update_column(:status, "accepted")
        @s_1.update_column(:status_approved, true)
        @s_1.update_column(:status_published, true)

        @p_1.update_column(:status, "approved")
        @p_1.update_column(:status_published, true)

        @s_1.reload
        @p_1.reload
      end

      it "should show the right students on the right pages" do
        visit(users_students_path(year: @q1.year, season: @q1.season))

        expect(current_path).to eq(users_students_path(year: @q1.year,
                                                       season: @q1.season))
        expect(page).to have_content(@s_1.student.first_name + " " +
                                     @s_1.student.last_name)
        expect(page).not_to have_content(@s_3.student.first_name + " " +
                                         @s_3.student.last_name)
        expect(page).to have_selector("table tr", maximum: 2)

        visit(users_students_path(year: @q2.year, season: @q2.season))
        expect(current_path).to eq(users_students_path(year: @q2.year,
                                                       season: @q2.season))
        expect(page).to have_content(@s_3.student.first_name + " " +
                                     @s_3.student.last_name)
        expect(page).not_to have_content(@s_1.student.first_name + " " +
                                         @s_1.student.last_name)
        expect(page).to have_selector("table tr", maximum: 2)
      end
    end
  end

  context "when an admin creates a project for an advisor in a quarter" do

  end

end
