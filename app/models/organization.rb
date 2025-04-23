class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy

  validates :name, presence: true
end