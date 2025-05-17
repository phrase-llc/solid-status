class StatusPage < ApplicationRecord
  belongs_to :organization

  # has_many :components, dependent: :destroy
  has_many :incidents, dependent: :destroy
  has_many :memberships, dependent: :destroy
  accepts_nested_attributes_for :memberships
  has_many :users, through: :memberships

  validates :name, presence: true
  validates :url, presence: true, uniqueness: true
end
