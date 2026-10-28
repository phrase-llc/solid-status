class Incident < ApplicationRecord
  belongs_to :status_page
  has_many :incident_entries, dependent: :destroy

  validates :title, :started_at, presence: true

  after_commit :enqueue_status_page_publication, on: %i[create update destroy]

  private

  def enqueue_status_page_publication
    PublishStatusPageJob.perform_later(status_page_id)
  end
end
