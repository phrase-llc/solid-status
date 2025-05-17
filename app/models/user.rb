class User < ApplicationRecord
  belongs_to :organization
  accepts_nested_attributes_for :organization
  has_many :memberships, dependent: :destroy
  has_many :pages, through: :memberships

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable, :timeoutable

  enum :role, {
    admin: "admin",
    member: "member"
  }

  validates :role, presence: true
  validates :first_name, :last_name, :display_name, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end

  def active_for_authentication?
    super && !disabled?
  end

  def inactive_message
    disabled? ? :disabled_account : super
  end
end
