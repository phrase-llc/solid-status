require 'rails_helper'

RSpec.describe 'Users', :js do
  let(:user) { create(:user) }
  let(:user_not_confirmed) { create(:user, confirmed_at: nil) }

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
end
