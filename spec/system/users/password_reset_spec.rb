require 'rails_helper'

RSpec.describe 'Users', :js do
  let(:user) { create(:user) }
  let(:user_not_confirmed) { create(:user, confirmed_at: nil) }

  describe 'パスワード再発行' do
    it 'パスワードが再発行できる' do
      visit new_user_session_path
      expect(page).to have_content 'パスワードを忘れましたか？'
      click_on 'パスワードを忘れましたか？'
      expect(page).to have_content 'パスワードを忘れましたか？'
      fill_in 'Eメール', with: user.email
      click_on 'パスワードの再設定方法を送信する'
      expect(page).to have_content 'パスワードの再設定について数分以内にメールでご連絡いたします'
    end

    it 'パスワード再発行画面からサインイン画面に戻れる' do
      visit new_user_password_path
      expect(page).to have_content 'パスワードを忘れましたか？'
      click_on 'サインイン'
      expect(page).to have_content 'サインイン'
    end
  end
end
