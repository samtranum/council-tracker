if Rails.env.development? || Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
  end
end

if Rails.env.production?
  require "cloudinary"
  require "cloudinary/carrierwave"

  Cloudinary.config do |config|
    config.cloud_name = ENV["CLOUDINARY_CLOUD_NAME"]
    config.api_key    = ENV["CLOUDINARY_API_KEY"]
    config.api_secret = ENV["CLOUDINARY_API_SECRET"]
    config.secure     = true
  end

  CarrierWave.configure do |config|
    config.storage        = :cloudinary
    config.cache_storage  = :file
  end
end
