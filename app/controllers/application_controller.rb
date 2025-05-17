require "application_responder"

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include AccessControllable
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Basic Auth
  http_basic_authenticate_with name: ENV.fetch("BASIC_AUTH_USERNAME", nil), password: ENV.fetch("BASIC_AUTH_PASSWORD", nil) if ENV["BASIC_AUTH_USERNAME"].present? && ENV["BASIC_AUTH_PASSWORD"].present?

  # Responders
  self.responder = ApplicationResponder
  respond_to :html

  private

  def verify_pundit?
    true
  end

  def user_not_authorized
    flash[:alert] = "権限がありません。"
    redirect_to(request.referer || root_path)
  end
end
