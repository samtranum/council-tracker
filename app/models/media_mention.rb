class MediaMention < ApplicationRecord
  belongs_to :mentionable, polymorphic: true, touch: true

  validates :body, presence: true
  validates :mentionable, presence: true
  validates :published_on, date: {allow_blank: true}

  after_initialize :set_published_on
  after_create_commit :fetch_og_image

  def domain
    return "" unless url.present?
    URI.parse(url).host.gsub("www.", "")
  rescue
    nil
  end

  private

  def set_published_on
    return if published_on.present? || persisted?
    self.published_on = Date.current
  end

  def fetch_og_image
    return if image_url.present? || url.blank?
    fetched = OgImageFetcher.fetch(url)
    update_column(:image_url, fetched) if fetched.present?
  end
end
