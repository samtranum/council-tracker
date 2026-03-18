class Council < ApplicationRecord
  has_many :user_councils, dependent: :destroy
  has_many :users, through: :user_councils

  has_many :council_sessions
  has_many :councillors
  has_many :local_electoral_areas

  validates :name, presence: true
  validates :slug, presence: true

  scope :active, -> { where(active: true) }
  scope :by_name, -> { order(:name) }

  def to_param
    slug
  end
end
