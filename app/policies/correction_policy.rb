class CorrectionPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    admin? || (record.council && can_access_council?(record.council))
  end

  def destroy?
    admin? || (record.council && can_access_council?(record.council))
  end

  class Scope < Scope
    def resolve
      if user.is_admin?
        scope.all
      else
        scope.where(council_id: user.council_ids)
      end
    end
  end
end
