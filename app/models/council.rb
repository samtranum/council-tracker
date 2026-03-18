class Council < ApplicationRecord
  has_many :user_councils, dependent: :destroy
  has_many :users, through: :user_councils

  has_many :corrections, dependent: :nullify

  has_many :council_sessions
  has_many :councillors
  has_many :local_electoral_areas

  has_many :meetings, through: :council_sessions
  has_many :motions, through: :meetings

  validates :name, presence: true
  validates :slug, presence: true

  scope :active, -> { where(active: true) }
  scope :by_name, -> { order(:name) }

  def to_param
    slug
  end
end
