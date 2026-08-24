class StatusPage < ApplicationRecord
  belongs_to :organization

  # has_many :components, dependent: :destroy
  has_many :incidents, dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true, uniqueness: true
end
