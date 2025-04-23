class Incident < ApplicationRecord
  belongs_to :product
  has_many :incident_entries, dependent: :destroy

  validates :title, :started_at, presence: true
end
