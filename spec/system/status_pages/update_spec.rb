require 'rails_helper'

describe 'ページの編集', :js do
  let(:organization) { create(:organization) }
  let(:editor_user) { create(:user, :admin, organization: organization) }
  let(:viewer_user) { create(:user, :member, organization: organization) }
  let(:status_page) { create(:status_page, organization: organization) }

  it '管理者であれば更新できる' do
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
    visit edit_status_page_path(status_page)
    expect(page).to have_content '権限がありません'
  end
end
