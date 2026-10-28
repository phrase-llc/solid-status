class UnpublishStatusPageJob < ApplicationJob
  queue_as :default

  retry_on Aws::S3::Errors::ServiceError, Seahorse::Client::NetworkingError, wait: :polynomially_longer, attempts: 5

  def perform(slug)
    StatusPagePublishing::Publisher.new(nil).unpublish(slug)
  end
end
