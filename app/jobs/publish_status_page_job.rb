class PublishStatusPageJob < ApplicationJob
  queue_as :default

  retry_on Aws::S3::Errors::ServiceError, Seahorse::Client::NetworkingError, wait: :polynomially_longer, attempts: 5

  def perform(status_page_id)
    StatusPagePublication.pending.where(status_page_id: status_page_id).find_each(&:process!)
  end
end
