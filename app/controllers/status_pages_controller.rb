class StatusPagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status_page, only: %i[show edit update destroy]

  def index
    @status_pages = policy_scope(StatusPage)
  end

  def show
    authorize @status_page
  end

  def new
    @status_page = current_user.organization.status_pages.build
    authorize @status_page
  end

  def create
    @status_page = current_user.organization.status_pages.build(status_page_params)
    authorize @status_page
    @status_page.save
    respond_with @status_page, location: status_pages_path
  end

  def edit
    authorize @status_page
  end

  def update
    authorize @status_page
    @status_page.update(status_page_params)
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
    params.require(:status_page).permit(:name, :slug)
  end
end
