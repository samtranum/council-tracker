class LogoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include Cloudinary::CarrierWave if Rails.env.production?

  def filename
    "logo.png"
  end

  def store_dir
    "councils/#{model.slug}"
  end

  version :header do
    process resize_to_fit: [400, 120]
  end
end
