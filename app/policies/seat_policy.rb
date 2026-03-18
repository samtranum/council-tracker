class SeatPolicy < ApplicationPolicy
  # All editors can manage seats for now.
  # Council-scoped enforcement will be added when council_id is added to the data model.
end
