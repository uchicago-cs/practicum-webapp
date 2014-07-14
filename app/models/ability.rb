class Ability
  include CanCan::Ability

  def initialize(user)
    
    user ||= User.new
    # If the user is not already signed in, we create a "guest account"
    # for them so that the authorizations below are still applied.

    # Cannot do any of the below initially (if we sign up as a new user)
    # since a user's role is "" by default.
    
    if user.admin?
      
      can :manage, :all
      can :approve, :all
      # can :update, Project
      # can :assign_roles
      # can :approve_users
      
    elsif user.advisor?

      can :create, Project
      can :read, Project
      # NOTE: The following abilities with conditions (by blocks) probably
      # do not work. 
      can :update, Project, approved: false
      
      can :read, Submission do |submission|
        project = Project.find_by(submission.try(:project_id))
        user.id == project.try(:advisor_id)
      end

      can :read, User, id: user.id

      can :accept, Submission
      can :reject, Submission

    elsif user.student?
      # Student abilities.

      can :read, Project, approved: true
      # User X can read a project if it has been approved.
      
      can :create, Submission
      # Submission.where.not(project_id: current_user.projects_applied_to)
      # User X can create a submission for a project if he has not already
      # done so.
      
      can :read, Submission, student_id: user.id
      # User X can read the submissions he has sent in.

      can :read, User, id: user.id
      
    else
      # A user who is none of the above, i.e., a guest who is not
      # signed in?
      # ... Cannot do very much.
      
    end
    
  end

end
