class Councillor < ApplicationRecord
  belongs_to :council
  has_many :seats
  has_many :attendances
  has_many :votes
  has_many :media_mentions, as: :mentionable
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

  def to_param
    slug_was
  end

  def seat
    @seat ||= seat_on(Date.current)
  end

  def seat_on(date)
    seats.active_on(date).take
  end

  def seat_for_session(council_session)
    council_session.seats.where(councillor_id: id).take
  end

  def active_on?(date)
    seats.active_on(date).any?
  end

  def party
    @party ||= seats.order("commenced_on desc").take.party
  end

  # lol
  def party_on(date)
    seat_on(date).party
  end

  def party_name
    party.present? ? party.name : ""
  end

  def local_electoral_area
    @local_electoral_area ||= seats.order("commenced_on desc").take.local_electoral_area
  end

  def local_electoral_area_name
    local_electoral_area.present? ? local_electoral_area.name : ""
  end

  def vote_on(motion)
    votes.where(voteable: motion).take
  end

  def attended?(meeting)
    attendances.attended.where(attendable: meeting).present?
  end

  def proposed_motions
    Motion.proposed_by(self)
  end

  def proposed_amendments
    Amendment.proposed_by(self)
  end

  def events
    Event.related_to_seats(seats.map(&:id).compact).order("occurred_on desc")
  end

  private

  def set_full_name
    self.full_name = "#{given_name} #{family_name}".strip
  end

  def set_given_and_family_names
    pcs = full_name.strip.split(" ")
    self.family_name = pcs.pop
    self.given_name = pcs.join(" ")
  end

  def generate_sort_name
    self.sort_name = "#{family_name}, #{given_name}"
  end

  def generate_slug
    return unless full_name

    self.slug = if Councillor.where(slug: full_name.parameterize)
        .where.not(id: id).any?
      n = 1
      while self.class.where(slug: "#{full_name.parameterize}-#{n}").any?
        n += 1
      end
      "#{full_name.parameterize}-#{n}"
    else
      full_name.parameterize
    end
  end

  def create_initial_seat
    return unless party_id.present? && local_electoral_area_id.present? && commenced_on.present? && council_id.present?

    # Find or create a session covering this date
    session = CouncilSession.where(council_id: council_id).current_on(commenced_on).take
    unless session
      # If no session exists for this date, we might need to create one or error out.
      # For now, let's assume one should exist or we create a "term" based on standard logic if needed.
      # But to be safe and simple, let's just try to find the latest one or create a new one if completely empty.
      # Actually, let's just create one if it doesn't exist, assuming a 5 year term? Or just open ended.
      session = CouncilSession.create!(council_id: council_id, commenced_on: commenced_on)
    end

    seat = seats.create!(
      council_session: session,
      local_electoral_area_id: local_electoral_area_id,
      commenced_on: commenced_on
    )
    
    seat.party = Party.find(party_id)
    seat.save!
  end
end
