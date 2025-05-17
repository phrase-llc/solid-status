require 'rails_helper'

RSpec.describe 'StatusPages', :js do
  let_it_be(:organization) { create(:organization) }
  let_it_be(:admin) { create(:user, :admin, organization: organization) }
  let_it_be(:member) { create(:user, :member, organization: organization) }
  # let(:status_page) { create(:status_page, organization: organization) }

  describe '作成' do
    it '管理者であれば作成できる' do
      sign_in admin
      visit new_status_page_path
      expect(page).to have_content 'ページ'
      fill_in 'ページ名', with: Faker::Game.title
      fill_in 'URL', with: Faker::Internet.url(host: 'example.com')
      click_on '登録する'
      expect(page).to have_content 'ページが作成されました'
    end

    it 'メンバーであれば作成できない' do
      sign_in member
      visit new_status_page_path
      expect(page).to have_content '権限がありません。'
    end
  end
end
