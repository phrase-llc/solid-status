class Incident < ApplicationRecord
  belongs_to :status_page
  has_many :incident_entries, dependent: :destroy

  validates :title, :started_at, presence: true

  after_save :record_status_page_publication
  after_destroy :record_status_page_publication, unless: :destroyed_by_association
  after_commit :enqueue_status_page_publication, on: %i[create update destroy], unless: :destroyed_by_association

  private

  def record_status_page_publication
    StatusPagePublication.request!(status_page)
  end

  def enqueue_status_page_publication
    StatusPagePublication.enqueue(PublishStatusPageJob, status_page_id)
  end
end
