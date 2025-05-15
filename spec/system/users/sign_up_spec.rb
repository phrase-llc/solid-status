require 'rails_helper'

RSpec.describe 'Users', :js do
  describe 'サインアップ' do
    it 'サインアップできる' do
      visit new_user_registration_path

      fill_in '姓', with: '山田'
      fill_in '名', with: '太郎'
      fill_in 'Eメール', with: 'test@example.com'
      fill_in '組織名', with: 'テスト会社'
      fill_in 'パスワード', with: 'password'
      fill_in 'パスワード（確認用）', with: 'password'
      click_on 'アカウント登録'

      expect(page).to have_content '本人確認用のメールを送信しました。メール内のリンクからアカウントを有効化させてください。'
    end
  end
end
