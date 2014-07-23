class Ability
  include CanCan::Ability

  def initialize(user)

    user ||= User.new
    if user.new_record?
      can :read, Project, status: "accepted"
    else
      if user.admin?
        can :manage, :all
      end

      if user.advisor?
        can :create, Project
        can :update, Project, status: "pending"
        can :read, User, id: user.id
        can :update, User, id: user.id

        can :read, Project do |project|
          project.status == "approved" or project.advisor_id == user.id
        end

        # "The block is only evaluated when an actual instance object is
        # present. It is not evaluated when checking permissions on the
        # class (such as in the index action). This means any conditions
        # which are not dependent on the object attributes should be moved
        # outside of the block."
        # https://github.com/ryanb/cancan/wiki/
        # Defining-Abilities-with-Blocks#only-for-object-attributes

        # Not DRY.
        # Also, for blocks, need to pass in an instance variable in the view.
        can :accept, Submission do |submission|
          submission.project_advisor_id == user.id
        end
        can :reject, Submission do |submission|
          submission.project_advisor_id == user.id
        end
        can :download_resume, Submission do |submission|
          submission.project_advisor_id == user.id
        end
        can :read, Submission do |submission|
          submission.project_advisor_id == user.id
        end

        can :read_submissions_of, Project do |project|
          project.advisor_id == user.id
        end

        can :create_evaluation_for, Submission do |submission|
          (submission.project_advisor_id == user.id) \
          and submission.accepted?
        end

        can :create, Evaluation
        can :read, Evaluation, advisor_id: user.id
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
end
