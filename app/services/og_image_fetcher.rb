class OgImageFetcher
  def self.fetch(url)
    return nil if url.blank?

    response = HTTParty.get(url, timeout: 5, follow_redirects: true, headers: {
      'User-Agent' => 'Mozilla/5.0 (compatible; CouncilVoteTracker)'
    })
    return nil unless response.success?

    doc = Nokogiri::HTML(response.body)

    # Try og:image first, then twitter:image
    tag = doc.at('meta[property="og:image"]') ||
          doc.at('meta[name="twitter:image"]') ||
          doc.at('meta[name="twitter:image:src"]')

    tag&.attr('content').presence
  rescue StandardError
    nil
  end
end
