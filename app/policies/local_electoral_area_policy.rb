class LocalElectoralAreaPolicy < ApplicationPolicy
  # All editors can manage LEAs for now.
  # Council-scoped enforcement will be added when council_id is added to local_electoral_areas.
end
