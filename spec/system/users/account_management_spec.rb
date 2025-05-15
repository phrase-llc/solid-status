require 'rails_helper'

RSpec.describe 'Users', :js do
  let(:user) { create(:user) }
  let(:user_not_confirmed) { create(:user, confirmed_at: nil) }

  describe 'アカウント設定' do
    it 'パスワードが変更できる' do
      sign_in user
      visit edit_user_registration_path
      expect(page).to have_content "アカウント情報変更"
      fill_in '現在のパスワード', with: user.password
      fill_in '新しいパスワード', with: 'password2'
      fill_in '新しいパスワード（再入力）', with: 'password2'
      click_on '更新'
      expect(page).to have_content I18n.t('devise.registrations.updated')
    end
  end
end
