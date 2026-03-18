class UserCouncil < ApplicationRecord
  belongs_to :user
  belongs_to :council

  validates :council_id, uniqueness: {scope: :user_id}
end
