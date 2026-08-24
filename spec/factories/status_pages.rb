FactoryBot.define do
  factory :status_page do
    sequence(:name) { |n| "Status page #{n}" }
    sequence(:slug) { |n| "status-#{n}" }
    organization
  end
end
