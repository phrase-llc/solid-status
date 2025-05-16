class Development::SessionsController < ActionController::Base # rubocop:disable Rails/ApplicationController
  def login_as
    user = User.find(params[:user_id])
    sign_in(user)
    cookies.signed[:user_id] = user.id
    redirect_to root_path, notice: "Signed in! [#{user.id}]"
  end
end
