class Seat < ApplicationRecord
  belongs_to :council_session, touch: true
  belongs_to :local_electoral_area, touch: true
  belongs_to :councillor, touch: true
  belongs_to :replaced_seat, class_name: "Seat", optional: true

  has_many :party_affiliations, autosave: true, dependent: :destroy
  has_many :replacement_seats, class_name: "Seat", foreign_key: "replaced_seat_id"

  enum term_type: { election: "election", co_option: "co_option" }

  validates :council_session, presence: true
  validates :local_electoral_area, presence: true
  validates :councillor, presence: true
  validates :replaced_seat_id, presence: true, if: :co_option?
  validate :replaced_seat_must_be_from_same_session

  delegate :full_name, to: :councillor

  scope :inactive, -> { inactive_on(Date.today) }
  scope :active, -> { active_on(Date.today) }
  scope :inactive_on, ->(date) { where("(seats.commenced_on <= ?) AND (seats.concluded_on <= ?)", date, date) }
  scope :active_on, ->(date) { where("(seats.commenced_on <= ?) AND ((seats.concluded_on IS NULL) OR (seats.concluded_on > ?))", date, date) }

  # should only be one per councillor per council_session
  def self.find_by_councillor_name(name)
    joins(:councillor).where(councillors: {full_name: name}).take
  end

  def party
    @party ||= party_affiliations.order("commenced_on DESC NULLS LAST").take.try(:party)
  end

  def party_id=(id)
    self.party = Party.find(id) if id.present?
  end

  def party=(party)
    if party_affiliations.any?
      # Update the most recent affiliation if it exists
      pa = party_affiliations.order("commenced_on DESC NULLS LAST").first
      pa.party = party
    else
      party_affiliations.build(party: party, commenced_on: nil)
    end
  end

  def set_party_affiliation_starting_on(party, date)
    party_affiliations.create(party: party, commenced_on: date)
  end

  def events
    @events ||= council_session.events.where("related_seat_ids @> ARRAY[CAST(? as bigint)]", id).order("occurred_on desc")
  end

  def election
    events.election.take
  end

  def display_term_type
    if co_option?
      "Co-opted on"
    else
      "Elected on"
    end
  end

  private

  def replaced_seat_must_be_from_same_session
    if replaced_seat_id.present? && replaced_seat.present?
      if replaced_seat.council_session_id != council_session_id
        errors.add(:replaced_seat_id, "must be from the same council session")
      end
    end
  end
end
