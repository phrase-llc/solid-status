class IncidentEntry < ApplicationRecord
  belongs_to :incident

  enum :status, {
    investigating: "investigating",
    identified: "identified",
    monitoring: "monitoring",
    resolved: "resolved",
    postmortem: "postmortem"
  }

  validates :status, presence: true
  validates :posted_at, presence: true

  after_commit :enqueue_status_page_publication, on: %i[create update destroy]

  private

  def enqueue_status_page_publication
    PublishStatusPageJob.perform_later(incident.status_page_id)
  end
end
