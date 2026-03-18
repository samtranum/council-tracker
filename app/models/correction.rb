class Correction < ApplicationRecord
  belongs_to :council, optional: true

  validates :body, presence: true
  validates :name, presence: true
  validates :email_address, presence: true

  paginates_per 20
end
