class CorrectionPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def destroy?
    admin?
  end
end
