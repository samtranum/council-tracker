class CouncilSessionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    can_access_council?(record.council)
  end

  def new?
    user.is_admin? || user.councils.any?
  end

  def create?
    can_access_council?(record.council)
  end

  def edit?
    can_access_council?(record.council)
  end

  def update?
    can_access_council?(record.council)
  end

  def destroy?
    can_access_council?(record.council)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.where(council: user.councils)
      end
    end
  end
end
