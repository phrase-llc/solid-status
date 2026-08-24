require "aws-sdk-s3"

module StatusPagePublishing
  class S3Storage
    def initialize(bucket:, client: Aws::S3::Client.new)
      @bucket = bucket
      @client = client
    end

    def write(key:, body:, content_type:, cache_control:)
      @client.put_object(
        bucket: @bucket,
        key: key,
        body: body,
        content_type: content_type,
        cache_control: cache_control
      )
    end

    def delete(key:)
      @client.delete_object(bucket: @bucket, key: key)
    end
  end
end
