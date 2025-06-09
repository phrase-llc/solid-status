
# Development environment seeds - test data for local development

puts "Creating development seed data..."

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
  body: "現在、APIがエラーを返す問題を調査しています。",
  posted_at: 1.hour.ago
)

puts "Development seed data created successfully!"
