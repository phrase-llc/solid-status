FactoryBot.define do
  factory :membership do
    association :user
    association :status_page
    role { "editor" }

    trait :editor do
      role { "editor" }
    end

    trait :viewer do
      role { "viewer" }
    end

    trait :unassigned do
      role { "unassigned" }
    end
  end
end
