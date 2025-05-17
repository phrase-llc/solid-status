FactoryBot.define do
  factory :status_page do
    name { Faker::Game.title }
    url  { Faker::Internet.url(host: 'example.com') }
    organization

    transient do
      editor_user { nil }
      viewer_user { nil }
      unassigned_user { nil }
    end

    trait :with_memberships do
      after(:create) do |status_page, evaluator|
        org = status_page.organization

        editor = evaluator.editor_user || create(:user, :admin, organization: org)
        viewer = evaluator.viewer_user || create(:user, :member, organization: org)
        unassigned = evaluator.unassigned_user || create(:user, :member, organization: org)

        create(:membership, status_page: status_page, user: editor, role: "editor")
        create(:membership, status_page: status_page, user: viewer, role: "viewer")
        create(:membership, status_page: status_page, user: unassigned, role: "unassigned")
      end
    end
  end
end
