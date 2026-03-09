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
    @party ||= seats.order("commenced_on desc").take&.party
  end

  # lol
  def party_on(date)
    seat_on(date)&.party
  end

  def party_name
    party.present? ? party.name : ""
  end

  def local_electoral_area
    @local_electoral_area ||= seats.order("commenced_on desc").take&.local_electoral_area
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

  def co_option_seats_without_events
    co_option_seats = seats.where(term_type: :co_option)
    return Seat.none if co_option_seats.empty?

    covered_seat_ids = Event.where("related_seat_ids && ARRAY[?]::bigint[]", co_option_seats.ids)
                            .flat_map(&:related_seat_ids)
    co_option_seats.where.not(id: covered_seat_ids).order(commenced_on: :desc)
  end

  def events
    seat_ids = seats.map(&:id).compact
    direct = Event.related_to_seats(seat_ids)

    # Also find election events for sessions this councillor was elected into,
    # in case their seat was added after the election was committed
    elected_session_ids = seats.where.not(term_type: :co_option)
                               .map(&:council_session_id).compact.uniq
    if elected_session_ids.any?
      commenced_ons = CouncilSession.where(id: elected_session_ids).pluck(:commenced_on)
      election_ids = Event.election.where(occurred_on: commenced_ons).ids
      return Event.where(id: direct.ids | election_ids).order("occurred_on desc")
    end

    direct
  end

  private

  def set_full_name
    self.full_name = "#{given_name} #{family_name}".strip
  end

  PREFIXES = %w(De Du Di Le La Van Von O Mc Mac Ni Ua Ui Ó Ní).freeze

  def set_given_and_family_names
    pcs = full_name.strip.split(" ")
    self.family_name = pcs.pop
    
    while pcs.any? && PREFIXES.include?(pcs.last)
      self.family_name = "#{pcs.pop} #{self.family_name}"
    end

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
    
    # Fallback to the latest session if none found for exact date (e.g. if commenced_on is slightly off)
    session ||= CouncilSession.where(council_id: council_id).latest

    unless session
      raise "No active council session found for this council. Please create a Council Session first."
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
