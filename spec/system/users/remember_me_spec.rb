require 'rails_helper'

RSpec.describe 'Users', :js do
  let(:user) { create(:user) }
  let(:user_not_confirmed) { create(:user, confirmed_at: nil) }

  describe 'サインインの有効期限' do
    it 'リメンバー機能が無効なとき24時間経過するとサインアウトされる' do
      visit new_user_session_path
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      click_on 'サインイン'
      expect(page).to have_content 'サインインしました。'

      # 2時間後に再度アクセスしてもセッションが有効であることを確認
      travel 2.hours do
        visit root_path
        expect(page).to have_current_path(root_path)
      end

      # 2 + 15時間後に再度アクセスしてもセッションが有効であることを確認
      travel 15.hours do
        visit root_path
        expect(page).to have_current_path(root_path)
      end

      # 2 + 15 + 25 時間後に再度アクセスした際にセッションが無効になっていることを確認
      travel 42.hours do
        visit root_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end

    it 'リメンバー機能が有効なときは7日間でサインアウトされる' do
      visit new_user_session_path
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      execute_script("document.getElementById('user_remember_me').click()")
      click_on 'サインイン'
      expect(page).to have_content 'サインインしました。'

      travel 8.days do
        visit root_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end

    it 'リメンバー期間が延長される' do
      visit new_user_session_path
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      execute_script("document.getElementById('user_remember_me').click()")
      click_on 'サインイン'
      expect(page).to have_content 'サインインしました。'

      # remember_meのクッキーが設定されていることを確認
      # capybara-playwright-driverでは未サポート
      # expect(page.driver.browser.manage.cookie_named('remember_user_token')).not_to be_nil

      # 6日後に再度アクセスしてもセッションが有効であることを確認
      travel 6.days do
        visit root_path
        expect(page).to have_current_path(root_path)
      end

      # さらに6日後に再度アクセスしてもセッションが有効であることを確認
      travel 6.days do
        visit root_path
        expect(page).to have_current_path(root_path)
      end

      # さらに8日後にアクセスした際にセッションが無効になっていることを確認
      travel 8.days do
        visit root_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
