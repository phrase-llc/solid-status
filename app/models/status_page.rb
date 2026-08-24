class StatusPage < ApplicationRecord
  belongs_to :organization

  # has_many :components, dependent: :destroy
  has_many :incidents, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\z/, message: "は英小文字・数字・ハイフンで指定してください" }

  after_commit :enqueue_publication, on: %i[create update]
  after_update_commit :enqueue_previous_slug_removal, if: :saved_change_to_slug?
  after_destroy_commit :enqueue_removal

  def public_host
    "#{slug}.#{Rails.configuration.x.status_pages.base_domain}"
  end

  def public_url
    "https://#{public_host}"
  end

  private

  def enqueue_publication
    PublishStatusPageJob.perform_later(id)
  end

  def enqueue_previous_slug_removal
    UnpublishStatusPageJob.perform_later(slug_before_last_save)
  end

  def enqueue_removal
    UnpublishStatusPageJob.perform_later(slug)
  end
end
