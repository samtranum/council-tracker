class AmendmentPolicy < ApplicationPolicy
  # All editors can manage amendments for now.
  # Council-scoped enforcement will be added when council_id is added to the data model.

  def save_vote?
    user.present?
  end
end
