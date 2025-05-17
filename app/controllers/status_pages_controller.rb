class StatusPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status_page, only: %i[show edit update destroy]
  # before_action -> { authorize(StatusPage) }, only: %i[create]
  before_action -> { authorize(@status_page) }, only: %i[edit update destroy show]

  def index
    @status_pages = policy_scope(StatusPage)
  end

  def show
    authorize @status_page
  end

  def new
    @status_page = current_user.organization.status_pages.build
    authorize @status_page

    current_user.organization.users.each do |user|
      role = user == current_user ? "editor" : "viewer"
      @status_page.memberships.build(user: user, role: role)
    end
  end

  def create
    @status_page = current_user.organization.status_pages.build(status_page_params)
    authorize @status_page
    unless @status_page.save
      current_user.organization.users.each do |user|
        @status_page.memberships.build(user: user) unless @status_page.memberships.any? { |m| m.user_id == user.id }
      end
    end
    respond_with @status_page, location: status_pages_path
  end

  def edit
    authorize @status_page
    ensure_all_memberships_present(@status_page)
  end

  def update
    authorize @status_page
    @status_page.update(status_page_params)
    ensure_all_memberships_present(@status_page) unless @status_page.errors.empty?
    respond_with @status_page, location: status_pages_path
  end

  def destroy
    authorize @status_page
    @status_page.destroy
    respond_with @status_page, location: status_pages_path
  end

  private

  def set_status_page
    @status_page = StatusPage.find(params[:id])
  end

  def status_page_params
    params.require(:status_page).permit(:name, :url, memberships_attributes: [:id, :user_id, :role])
  end

  def ensure_all_memberships_present(status_page)
    existing_user_ids = status_page.memberships.map(&:user_id).compact.uniq

    missing_users = status_page.organization.users.where.not(id: existing_user_ids)
    missing_users.each do |user|
      status_page.memberships.build(user: user, role: "unassigned")
    end
  end
end
