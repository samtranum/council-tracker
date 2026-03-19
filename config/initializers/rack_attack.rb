class Rack::Attack
  # Throttle requests to 60 per minute per IP
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Stricter limit on paginated index pages (the scraper target)
  throttle("pagination/ip", limit: 30, period: 1.minute) do |req|
    req.ip if req.path =~ /\/(councillors|motions|meetings|votes)/ && req.params["p"].present?
  end

  # Return 429 with a plain message when throttled
  self.throttled_responder = lambda do |env|
    [429, { "Content-Type" => "text/plain" }, ["Too many requests. Please slow down.\n"]]
  end
end
