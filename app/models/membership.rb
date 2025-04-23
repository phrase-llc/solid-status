class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :product

  enum :role, {
    viewer: "viewer",
    editor: "editor"
  }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :product_id } # 重複防止
end
