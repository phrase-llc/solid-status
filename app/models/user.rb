class User < ApplicationRecord
  belongs_to :organization
  accepts_nested_attributes_for :organization
  has_many :memberships, dependent: :destroy
  has_many :products, through: :memberships

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable, :timeoutable

  validates :first_name, :last_name, :display_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
