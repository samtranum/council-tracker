class Council < ApplicationRecord
  has_many :council_sessions
  has_many :councillors
  has_many :local_electoral_areas

  has_many :meetings, through: :council_sessions
  has_many :motions, through: :meetings

  def to_param
    slug
  end
end
