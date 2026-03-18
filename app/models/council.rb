class Council < ApplicationRecord
  has_many :user_councils, dependent: :destroy
  has_many :users, through: :user_councils

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :active, -> { where(active: true) }
  scope :by_name, -> { order(:name) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
