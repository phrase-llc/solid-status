require 'rails_helper'

RSpec.describe 'Users', :js do
  let(:user) { create(:user, disabled: true) }

  describe 'アカウントが無効' do
    it 'サインインできない' do
      visit new_user_session_path
      expect(page).to have_content 'サインイン'
      fill_in 'Eメール', with: user.email
      fill_in 'パスワード', with: user.password
      click_on 'サインイン'
      expect(page).to have_content 'このアカウントは現在使用できません'
    end
  end
end
