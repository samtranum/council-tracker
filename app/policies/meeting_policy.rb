class MeetingPolicy < ApplicationPolicy
  # All editors can manage meetings for now.
  # Council-scoped enforcement will be added when council_id is added to meetings.

  def scrape?
    admin?
  end

  def save_attendance?
    user.present?
  end
end
