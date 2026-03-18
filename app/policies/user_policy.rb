class UserPolicy < ApplicationPolicy
  # Only admins can manage users
  def index?
    admin?
  end

  def show?
    admin?
  end

  def new?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    admin? || record == user
  end

  def update?
    admin? || record == user
  end

  def destroy?
    admin? && record != user
  end

  def change_password?
    record == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
