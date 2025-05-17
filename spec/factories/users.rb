FactoryBot.define do
  factory :user do
    transient do
      gimei { Gimei.name }
    end

    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    confirmed_at { Time.current }
    last_name { gimei.last.kanji }
    first_name { gimei.first.kanji }
    display_name { "#{last_name} #{first_name}" }
    organization
    role { 'member' }
    disabled { false }

    trait :admin do
      role { 'admin' }
    end

    trait :member do
      role { 'member' }
    end
  end
end
