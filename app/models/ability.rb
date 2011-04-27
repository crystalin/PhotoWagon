class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    alias_action :recreate_images, :to => :manage
    alias_action :picasa, :picasa_upload, :to => :create
    alias_action :recent, :beginning, :to => :read



    if user.role? :admin
      can :manage, :all
    else
      can :read, :all
      can :create, Comment
      can :update, User do |selected_user|
        selected_user.id == user.id
      end
    end
  end
end