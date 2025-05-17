class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :page

  enum :role, {
    viewer: "viewer",
    editor: "editor"
  }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :page_id } # 重複防止
end
