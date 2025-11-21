class Council < ApplicationRecord
  has_many :council_sessions
  has_many :councillors
  has_many :local_electoral_areas

  def to_param
    slug
  end
end
