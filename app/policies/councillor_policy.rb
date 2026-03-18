class CouncillorPolicy < ApplicationPolicy
  # All editors can manage councillors for now.
  # Council-scoped enforcement will be added when council_id is added to councillors.
end
