require 'rails_helper'

describe 'ページの編集', :js do
  let(:organization) { create(:organization) }
  let(:editor_user) { create(:user, :admin, organization: organization) }
  let(:viewer_user) { create(:user, :member, organization: organization) }
  let(:unassigned_user) { create(:user, :member, organization: organization) }
  let(:status_page) { create(:status_page, :with_memberships, organization: organization, editor_user: editor_user) }
  let(:viewer_page) { create(:status_page, :with_memberships, organization: organization, viewer_user: viewer_user) }
  let(:unassigned_page) { create(:status_page, :with_memberships, organization: organization, unassigned_user: unassigned_user) }

  it 'editorであれば更新できる' do
    sign_in editor_user
    visit edit_status_page_path(status_page)

    expect(page).to have_content 'ページ'
    fill_in 'ページ名', with: Faker::Game.title
    fill_in 'URL', with: Faker::Internet.url(host: 'example.com')
    click_on '更新する'

    expect(page).to have_content 'ページが更新されました'
  end

  it 'viewであれば更新できない' do
    sign_in viewer_user
    visit edit_status_page_path(viewer_page)
    expect(page).to have_content '権限がありません'
  end

  it 'unassignedであれば更新できない' do
    sign_in unassigned_user
    visit edit_status_page_path(unassigned_page)
    expect(page).to have_content '権限がありません'
  end
end
