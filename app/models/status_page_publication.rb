class StatusPagePublication < ApplicationRecord
  scope :pending, -> { where(pending: true) }

  def self.enqueue(job_class, *args)
    job_class.perform_later(*args)
  rescue SolidQueue::Job::EnqueueError => error
    Rails.error.report(error, handled: true)
  end

  def self.request!(status_page, slug: status_page.slug)
    transaction do
      publication = create_or_find_by!(slug: slug) do |record|
        record.status_page_id = status_page.id
      end

      publication.with_lock do
        unless publication.status_page_id == status_page.id
          status_page.errors.add(:slug, :taken)
          raise ActiveRecord::RecordInvalid, status_page
        end

        publication.update!(pending: true)
      end

      publication
    end
  end

  def process!
    with_lock do
      return unless pending?

      status_page = StatusPage.find_by(id: status_page_id, slug: slug)

      if status_page
        StatusPagePublishing::Publisher.new(status_page).publish
      else
        StatusPagePublishing::Publisher.new(nil).unpublish(slug)
      end

      update!(pending: false)
    end
  end
end
