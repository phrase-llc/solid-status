class ReconcileStatusPagePublicationsJob < ApplicationJob
  queue_as :default

  def perform
    StatusPagePublication.pending.find_each do |publication|
      begin
        publication.process!
      rescue Aws::S3::Errors::ServiceError, Seahorse::Client::NetworkingError => error
        Rails.error.report(error, handled: true)
      end
    end
  end
end
