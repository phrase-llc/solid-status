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

  after_save :record_status_page_publication
  after_destroy :record_status_page_publication, unless: :destroyed_by_association
  after_commit :enqueue_status_page_publication, on: %i[create update destroy], unless: :destroyed_by_association

  private

  def record_status_page_publication
    StatusPagePublication.request!(incident.status_page)
  end

  def enqueue_status_page_publication
    StatusPagePublication.enqueue(PublishStatusPageJob, incident.status_page_id)
  end
end
