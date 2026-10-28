module StatusPagePublishing
  class Storage
    def self.build
      bucket = Rails.configuration.x.status_pages.s3_bucket
      return LocalStorage.new(root: Rails.configuration.x.status_pages.local_output_path) if bucket.blank? && !Rails.env.production?

      raise "STATUS_PAGE_S3_BUCKET must be set in production" if bucket.blank?

      S3Storage.new(bucket: bucket)
    end
  end
end
