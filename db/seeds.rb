# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

organization = Organization.find_or_create_by!(name: "Acme Inc")

product = organization.products.find_or_create_by!(
  name: "API Service",
  domain: "api.acme-status.com"
)

user = User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password"
  u.organization = organization
  u.confirmed_at = Time.current  # confirmable の対応
end

Membership.find_or_create_by!(user: user, product: product) do |m|
  m.role = "editor"
end

incident = product.incidents.find_or_create_by!(
  title: "認証エラーの障害",
  started_at: 1.hour.ago
)

incident.incident_entries.find_or_create_by!(
  status: "investigating",
  body: "現在、APIがエラーを返す問題を調査しています。"
)
