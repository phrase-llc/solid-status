class Organization < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :pages, dependent: :destroy

  validates :name, presence: true
end
