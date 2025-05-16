# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  layout "application", only: %i[edit]

  def new
    build_resource({})
    resource.build_organization # 組織を初期化
    respond_with resource
  end

  # POST /resource
  def create
    build_resource(sign_up_params)

    if resource.save
      yield resource if block_given?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def after_inactive_sign_up_path_for(resource)
    new_user_session_path
  end

  def sign_up_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :first_name, :last_name, :display_name,
      organization_attributes: [ :name ]
    )
  end
end
