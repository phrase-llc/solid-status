module AccessControllable
  extend ActiveSupport::Concern

  included do
    include Pundit::Authorization
    after_action :verify_authorized, except: :index, if: :verify_pundit?
    after_action :verify_policy_scoped, only: :index, if: :verify_pundit?
  end

  private

  def verify_pundit?
    true
  end
end
