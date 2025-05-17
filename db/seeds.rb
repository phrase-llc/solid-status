# This file should ensure the existence of records required to run the application in every environment (status_pageion,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

organization = Organization.find_or_create_by!(name: "Acme Inc")

status_page = organization.status_pages.find_or_create_by!(
  name: "API Service",
  url: "api.acme-status.com"
)

user = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password"
  u.organization = organization
  u.confirmed_at = Time.current  # confirmable の対応
  u.first_name = "太郎"
  u.last_name = "山田"
  u.display_name = "山田 太郎"
  u.role = "admin"
end

Membership.find_or_create_by!(user: user, status_page: status_page) do |m|
  m.role = "editor"
end

incident = status_page.incidents.find_or_create_by!(
  title: "認証エラーの障害",
  started_at: 1.hour.ago
)

incident.incident_entries.find_or_create_by!(
  status: "investigating",
  body: "現在、APIがエラーを返す問題を調査しています。"
)
