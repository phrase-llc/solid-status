class Incident < ApplicationRecord
  belongs_to :page
  has_many :incident_entries, dependent: :destroy

  validates :title, :started_at, presence: true
end
