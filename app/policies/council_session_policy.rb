class CouncilSessionPolicy < ApplicationPolicy
  # All editors can manage council sessions for now.
  # Council-scoped enforcement will be added when council_id is added to council_sessions.
end
