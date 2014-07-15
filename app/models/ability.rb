class Ability
  include CanCan::Ability

  def initialize(user)
    
    user ||= User.new
    
    if user.admin?
      
      can :manage, :all
      can :approve, :all
      
    elsif user.advisor?

      can :create, Project
      can :read, Project
      can :update, Project, approved: false
      can :read, User, id: user.id
      can :accept, Submission
      can :reject, Submission

      # Do block abilities work?
      can :read, Submission do |submission|
        project = Project.find_by(submission.try(:project_id))
        user.id == project.try(:advisor_id)
      end

    elsif user.student?

      can :read, Project, approved: true
      can :read, User, id: user.id
      can :create, Submission
      can :read, Submission, student_id: user.id
      
    end
  end
end
