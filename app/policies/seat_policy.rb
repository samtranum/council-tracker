class SeatPolicy < ApplicationPolicy
  def index?
    can_access_council?(record.council_session.council)
  end

  def show?
    can_access_council?(record.council_session.council)
  end

  def new?
    user.is_admin? || user.councils.any?
  end

  def create?
    can_access_council?(record.council_session.council)
  end

  def edit?
    can_access_council?(record.council_session.council)
  end

  def update?
    can_access_council?(record.council_session.council)
  end

  def destroy?
    can_access_council?(record.council_session.council)
  end
end
