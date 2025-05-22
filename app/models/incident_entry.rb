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
end
