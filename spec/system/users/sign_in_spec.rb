require 'rails_helper'

RSpec.describe 'Users', :js do
  let(:user) { create(:user) }
  let(:user_not_confirmed) { create(:user, confirmed_at: nil) }

  describe 'サインイン' do
    it '登録済みアカウントでサインインできる' do
      visit new_user_session_path
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      click_on 'サインイン'
      expect(page).to have_content 'サインインしました。'
    end

    it 'パスワードが違う場合はサインインできない' do
      visit new_user_session_path
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: 'wrong_password'
      click_on 'サインイン'
      expect(page).to have_content 'Eメールまたはパスワードが違います。'
    end

    it 'Eメールが違う場合はサインインできない' do
      visit new_user_session_path
      fill_in 'Eメール', with: 'wrong@example.com'
      fill_in 'パスワード', with: user.password
      click_on 'サインイン'
      expect(page).to have_content 'Eメールまたはパスワードが違います。'
    end

    it 'アクティブではないアカウントはサインインできない' do
      visit new_user_session_path
      fill_in 'Eメール', with: user_not_confirmed.email
      fill_in 'パスワード', with: user_not_confirmed.password
      click_on 'サインイン'
      expect(page).to have_content 'メールアドレスの本人確認が必要です。'
    end
  end

  describe 'サインアウト' do
    it 'サインイン済みアカウントでサインアウトできる' do
      sign_in(user)
      visit root_path
      expect(page).to have_content 'サインアウト'
      click_on 'サインアウト'
      expect(page).to have_content 'サインアウトしました。'
    end
  end
end
