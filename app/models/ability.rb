class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    can :read, Quarter

    if user.new_record?
      can :read, Project, status: "accepted", status_published: true
    else

      if user.admin?
        can :manage, :all
        can :destroy, Quarter, current: false
        cannot :clone, Project do |project|
          !project.cloneable?
        end
      end

      if user.advisor?
        can :create, Project
        can :my_projects, User, id: user.id
        can :read, User, id: user.id
        can :update, User, id: user.id
        can :create, Evaluation
        can :read, Evaluation, advisor_id: user.id
        can :update_affiliation_of, User, id: user.id
        submission_abilities(user, :accept, :reject, :read,
                             :accept_submission, :reject_submission)

        can :download_resume, Submission do |submission|
          submission.project_advisor_id == user.id and
            submission.resume.exists?
        end

        can :read, Project do |project|
          (project.status == "accepted" and project.status_published) or
            project.advisor_id == user.id
        end

        can :update, Project do |project|
          project.status == "pending" and project.advisor_id == user.id
        end

        can :read_submissions_of, Project do |project|
          project.advisor_id == user.id and project.submissions.count > 0
          # user.made_project?(project)
        end

        can :read_status_of, Project do |project|
          project.advisor_id == user.id
        end

        can :clone, Project do |project|
          user.made_project?(project) and project.cloneable?
        end

        can :create_evaluation_for, Submission do |submission|
          (submission.project_advisor_id == user.id) and
            submission.accepted? and !submission.evaluation
        end

        can :read, Evaluation do |evaluation|
          evaluation.advisor_id == user.id
        end
      end

      if user.student?
        can :read, Project, status: "accepted", status_published: true
        can :my_submissions, User, id: user.id
        can :read, User, id: user.id
        can :create, Submission
        can :read, Submission, student_id: user.id
        can :download_resume, Submission, student_id: user.id

        can :apply_to, Project do |project|
          project.accepted? and !user.applied_to_project?(project) and
            project.in_current_quarter? and project.status_published?
        end

        can :edit, Submission do |submission|
          submission.student_id == user.id
        end

        can :update, Submission do |submission|
          submission.student_id == user.id
        end

      end
    end
  end

  def submission_abilities(user, *actions)
    actions.each do |take_action|
      can take_action, Submission do |submission|
        submission.project_advisor_id == user.id
      end
    end
  end

end
