class CouncilPolicy < ApplicationPolicy
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
    admin? || can_access_council?(record)
  end

  def update?
    admin? || can_access_council?(record)
  end

  def destroy?
    admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.joins(:user_councils).where(user_councils: { user_id: user.id })
      end
    end
  end
end
