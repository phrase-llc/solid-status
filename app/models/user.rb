class User < ApplicationRecord
  belongs_to :organization
  has_many :memberships, dependent: :destroy
  has_many :products, through: :memberships

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable

  def full_name
    "#{first_name} #{last_name}"
  end
end
