# Defines user authorizations
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    id = user.id
    type = user.type

    # Default abilities
    can :read, Grant, state: 'crowdfunding'
    can :read, Recipient
    can :manage, User, id: id

    if type == 'SuperUser'
      can :manage, :all
      cannot :destroy, SuperUser
    elsif type == 'Admin'
      cannot :manage, [SuperUser, Admin]
      can :manage, Admin, id: id
      if user.approved
        can :manage, :all
        cannot :manage, SuperUser
        cannot :destroy, Admin
        can :read, :all
        can :rate, Grant
      end
    elsif type == 'Recipient'
      can :manage, Recipient, id: id
      if user.approved
        can [:create, :read], Grant
        can :manage, DraftGrant, recipient_id: id
        can :create, DraftGrant
        can :read, PreapprovedGrant
      end
    end
  end
end
