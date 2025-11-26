class Councillor < ApplicationRecord
  belongs_to :council
  has_many :seats, dependent: :destroy
  has_many :attendances, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :media_mentions, as: :mentionable, dependent: :destroy
  has_many :council_sessions, through: :seats

  has_many :meetings, through: :attendances, source: :attendable, source_type: "Meeting"

  validates :full_name, presence: true

  before_validation :set_full_name, if: ->(c) { c.given_name_changed? || c.family_name_changed? }
  before_validation :set_given_and_family_names, if: ->(c) { c.full_name_changed? }
  before_validation :generate_sort_name
  after_validation :generate_slug
  after_create :create_initial_seat

  attr_accessor :party_id, :local_electoral_area_id, :commenced_on

  scope :by_name, -> { order("sort_name asc") }
  scope :inactive_on, ->(date) { joins(:seats).merge(Seat.active_on(date)).distinct }
  scope :active_on, ->(date) { joins(:seats).merge(Seat.active_on(date)).distinct }

  mount_uploader :portrait, PortraitUploader, mount_on: :portrait_file

  paginates_per 20
end
