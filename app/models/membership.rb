class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :status_page

  enum :role, {
    viewer: "viewer",
    editor: "editor",
    unassigned: "unassigned"
  }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :status_page_id } # 重複防止
end
