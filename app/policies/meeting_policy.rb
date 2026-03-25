class MeetingPolicy < ApplicationPolicy
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
    council = record.council_session&.council || Council.find_by(id: record.council_id)
    can_access_council?(council)
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

  def scrape?
    admin?
  end

  def save_attendance?
    can_access_council?(record.council)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.joins(:council_session).where(council_sessions: {council: user.councils})
      end
    end
  end
end
