require 'rails_helper'

RSpec.describe 'Users', :js do
  let(:user) { create(:user) }
  let(:user_not_active) { create(:user, confirmed_at: nil) }

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
      expect(page).to have_content 'Eメール もしくはパスワードが正しくありません。'
    end

    it 'Eメールが違う場合はサインインできない' do
      visit new_user_session_path
      fill_in 'Eメール', with: 'wrong@example.com'
      fill_in 'パスワード', with: user.password
      click_on 'サインイン'
      expect(page).to have_content 'Eメール もしくはパスワードが正しくありません。'
    end

    it 'アクティブではないアカウントはサインインできない' do
      visit new_user_session_path
      fill_in 'Eメール', with: user_not_active.email
      fill_in 'パスワード', with: user_not_active.password
      click_on 'サインイン'
      expect(page).to have_content 'アカウントは無効になっています。'
    end

    xit '重複サインイン時はエラーメッセージが表示され unique_session_id にログが残る' do
      visit new_user_session_path
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      click_on 'サインイン'
      expect(page).to have_content 'Dashboard'

      using_session :another do
        visit new_user_session_path
        fill_in 'Eメール', with: user.email
        fill_in 'パスワード', with: user.password
        click_on 'サインイン'
        expect(page).to have_content 'Dashboard'
      end

      using_wait_time(20) do
        visit current_path
        expect(page).to have_content '他のブラウザでサインインされました。このブラウザで続ける場合は、もう一度サインインしてください。'
        expect(UserUniqueSessionIdLog.count).to eq(1)
      end
    end
  end

  describe 'サインインの有効期限' do
    before do
      sns_mock = instance_double(SnsClient)
      allow(SnsClient).to receive(:new).and_return(sns_mock)
      allow(sns_mock).to receive(:send_sms)
    end

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

    it 'リメンバー機能が有効なときは14日間でサインアウトされる' do
      visit new_user_session_path
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      execute_script("document.getElementById('user_remember_me').click()")
      click_on 'サインイン'
      expect(page).to have_content 'サインインしました。'

      travel 15.days do
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

      # 7日後に再度アクセスしてもセッションが有効であることを確認
      travel 7.days do
        visit root_path
        expect(page).to have_current_path(root_path)
      end

      # 7+13日後に再度アクセスしてもセッションが有効であることを確認
      travel 13.days do
        visit root_path
        expect(page).to have_current_path(root_path)
      end

      # 7 + 13 + 15 日後にアクセスした際にセッションが無効になっていることを確認
      travel 15.days do
        visit root_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe 'サインアウト' do
    it 'サインイン済みアカウントでサインアウトできる' do
      sign_in(user)
      visit root_path
      find(class: 'pro-pic').click
      click_on 'サインアウト', match: :first
      expect(page).to have_content 'サインアウトしました。'
    end
  end

  describe 'パスワード再発行' do
    it 'パスワードが再発行できる' do
      visit new_user_session_path
      expect(page).to have_content 'パスワードを忘れた方'
      click_on 'パスワードを忘れた方'
      expect(page).to have_content 'パスワード再発行'
      fill_in 'Eメール', with: user.email
      click_on 'メールを送る'
      expect(page).to have_content 'あなたのEメールが登録済みの場合、パスワード再設定用のメールが数分以内に送信されます。'
    end

    it 'パスワード再発行画面からサインイン画面に戻れる' do
      visit new_user_password_path
      expect(page).to have_content 'パスワード再発行'
      click_on 'サインインへ戻る'
      expect(page).to have_content 'サインイン'
    end
  end

  describe 'アカウント設定' do
    it 'パスワードが変更できる' do
      sign_in user
      visit edit_user_registration_path
      expect(page).to have_content user.email
      fill_in '現在のパスワード', with: user.password
      fill_in '新しいパスワード', with: 'password2'
      fill_in '新しいパスワードを再度入力', with: 'password2'
      click_on '変更する'
      expect(page).to have_content I18n.t('devise.registrations.updated')
    end
  end

  describe 'アカウントのロック' do
    # 実際にロックされるかどうかのテストはflakyだったのでrequest specで行う
    it 'ロックを解除できる' do
      user.lock_access!
      mail = ActionMailer::Base.deliveries.last
      body = mail.body.encoded
      token = body[/unlock_token=[^"]+/]
      visit "/users/unlock?#{token}"
      expect(page).to have_content 'アカウントをロック解除しました。'

      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      click_on 'サインイン'
      expect(page).to have_content 'サインインしました'
    end
  end

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
