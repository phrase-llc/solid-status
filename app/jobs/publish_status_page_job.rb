class PublishStatusPageJob < ApplicationJob
  queue_as :default

  retry_on Aws::S3::Errors::ServiceError, Seahorse::Client::NetworkingError, wait: :polynomially_longer, attempts: 5

  def perform(status_page_id)
    status_page = StatusPage.find_by(id: status_page_id)
    return unless status_page

    StatusPagePublishing::Publisher.new(status_page).publish
  end
end
