class User < ApplicationRecord
  authenticates_with_sorcery!
  validates :email_address, presence: true, uniqueness: true
  validates_presence_of :password, on: :create
  validates :password, length: {minimum: 8}, if: -> { password.present? }

  has_many :user_councils, dependent: :destroy
  has_many :councils, through: :user_councils

  def is_admin?
    admin
  end

  def editor?
    !admin
  end

  def can_access_council?(council)
    is_admin? || councils.include?(council)
  end
end
