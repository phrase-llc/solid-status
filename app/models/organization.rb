class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :status_pages, dependent: :destroy

  validates :name, presence: true
end
