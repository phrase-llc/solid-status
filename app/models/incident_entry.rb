class IncidentEntry < ApplicationRecord
  belongs_to :incident

  enum :status, {
    investigating: "investigating",
    identified: "identified",
    monitoring: "monitoring",
    resolved: "resolved"
  }

  validates :status, presence: true
end
