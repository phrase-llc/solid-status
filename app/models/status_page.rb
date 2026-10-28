class StatusPage < ApplicationRecord
  belongs_to :organization

  # has_many :components, dependent: :destroy
  has_many :incidents, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\z/, message: "は英小文字・数字・ハイフンで指定してください" }

  validate :slug_is_not_retired

  after_save :record_publication
  after_destroy :record_removal
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

  def slug_is_not_retired
    publication = StatusPagePublication.find_by(slug: slug)
    errors.add(:slug, :taken) if publication && publication.status_page_id != id
  end

  def record_publication
    StatusPagePublication.request!(self)
    StatusPagePublication.request!(self, slug: slug_before_last_save) if saved_change_to_slug? && slug_before_last_save.present?
  end

  def record_removal
    StatusPagePublication.request!(self)
  end

  def enqueue_publication
    StatusPagePublication.enqueue(PublishStatusPageJob, id)
  end

  def enqueue_previous_slug_removal
    StatusPagePublication.enqueue(UnpublishStatusPageJob, slug_before_last_save)
  end

  def enqueue_removal
    StatusPagePublication.enqueue(UnpublishStatusPageJob, slug)
  end
end
