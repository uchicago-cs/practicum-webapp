class Ability
  include CanCan::Ability

  def initialize(user)
    
    user ||= User.new
    # If the user is not already signed in, we create a "guest account"
    # for them so that the authorizations below are still applied.
    
    if user.admin?
      
      can :manage, :all
      # can :update, Project
      # can :assign_roles
      # can :approve_users
      
    elsif user.advisor?

      can :create, Project
      can :read, Project
      can :update, Project do |project|
        !(project.try(:approved))
      end
      
      can :read, Submission do |submission|
        project = Project.find_by(submission.try(:project_id))
        user.id == project.try(:advisor_id)
      end

    elsif user.student?
      
      can :read, Project
      
      can :create, Submission do |submission|
        # User has not already submitted an application for this project.
        true
      end
      can :read, Submission do |submission|
        user.id == submission.try(:user_id)
      end
      
    else
      # A user who is none of the above, i.e., a guest who is not
      # signed in?
      # ...
      # Cannot do very much.
      
    end
    
  end

end
