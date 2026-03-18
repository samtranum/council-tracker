class MotionPolicy < ApplicationPolicy
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

  def publish?
    can_access_council?(record.council)
  end

  def save_vote?
    can_access_council?(record.council)
  end

  def refresh_votes?
    can_access_council?(record.council)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.joins(meeting: :council_session).where(council_sessions: {council: user.councils})
      end
    end
  end
end
