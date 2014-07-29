class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    can :read, Quarter
    if user.new_record?
      can :read, Project, status: "accepted"
    else
      if user.admin?
        can :manage, :all
        can :destroy, Quarter, current: false
      end

      if user.advisor?
        can :create, Project
        can :read, User, id: user.id
        can :update, User, id: user.id
        can :create, Evaluation
        can :read, Evaluation, advisor_id: user.id
        submission_abilities(user, :accept, :reject, :download_resume, :read)

        can :read, Project do |project|
          project.status == "accepted" or project.advisor_id == user.id
        end

        can :update, Project do |project|
          project.status == "pending" and project.advisor_id == user.id
        end

        can :read_submissions_of, Project do |project|
          project.advisor_id == user.id
        end

        can :create_evaluation_for, Submission do |submission|
          (submission.project_advisor_id == user.id) \
            and submission.accepted?
        end
      end

      if user.student?
        can :read, Project, status: "accepted"
        can :read, User, id: user.id
        can :create, Submission
        can :read, Submission, student_id: user.id
        can :download_resume, Submission, student_id: user.id
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
