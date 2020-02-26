# frozen_string_literal: true

# rubocop:disable all
require 'timezone_finder'
require 'exifr/jpeg'
class ExifJpegAnalyzer < ActiveStorage::Analyzer::ImageAnalyzer
  def metadata
    read_image do |image|
      if rotated_image?(image)
        { width: image.height, height: image.width }
      else
        { width: image.width, height: image.height }
      end.merge(gps_from_exif(image))
    end
  rescue LoadError
    logger.info "Skipping image analysis because the mini_magick gem isn't installed"
    {}
  end

  private

  def ref(gps_ref)
    %w[N E].include?(gps_ref) ? 1 : -1
  end

  def gps_from_exif(image)
    {}.tap do |hash|
      next unless image.type == 'JPEG'
      next if image.is_a? ActiveStorage::Variant

      image_data = EXIFR::JPEG.new(image.path)
      if image_data.exif&.fields[:gps]
        latitude = image_data.gps_latitude.to_f * ref(image_data.gps_latitude_ref)
        longitude = image_data.gps_longitude.to_f * ref(image_data.gps_longitude_ref)
        time_zone = TimezoneFinder.create.timezone_at(lat: latitude, lng: longitude)
        date_time =
          "#{image_data.gps_date_stamp.split(':').join('-')} #{
            image_data.gps_time_stamp.collect(&:to_i).join(':')
          } UTC"
        hash[:latitude] = latitude
        hash[:longitude] = longitude
        hash[:altitude] = image_data.gps_altitude.to_f
        hash[:time_zone] = time_zone
        hash[:date_time] = date_time
      end
    end
  rescue EXIFR::MalformedImage, EXIFR::MalformedJPEG
  end
end

# https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html
Rails.application.config.active_storage
     .analyzers.delete ActiveStorage::Analyzer::ImageAnalyzer
Rails.application.config.active_storage.analyzers.append ExifJpegAnalyzer
# rubocop:enable all
