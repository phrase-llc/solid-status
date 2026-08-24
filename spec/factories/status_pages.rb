FactoryBot.define do
  factory :status_page do
    name { Faker::Game.title }
    url  { Faker::Internet.url(host: 'example.com') }
    organization
  end
end
