class MotionPolicy < ApplicationPolicy
  # All editors can manage motions for now.
  # Council-scoped enforcement will be added when council_id is added to the data model.

  def publish?
    user.present?
  end

  def save_vote?
    user.present?
  end

  def refresh_votes?
    user.present?
  end
end
