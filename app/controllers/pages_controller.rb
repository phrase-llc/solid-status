class PagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_page, only: %i[show edit update destroy]
  # after_action :verify_authorized
  # after_action :verify_policy_scoped, only: :index
  before_action -> { authorize(Page) }, only: %i[new create]
  before_action -> { authorize(@page) }, only: %i[edit update destroy show]

  def index
    @pages = policy_scope(Page)
  end

  def show
    authorize @page
  end

  def new
    @page = current_user.organization.pages.build
    authorize @page
  end

  def create
    @page = current_user.organization.pages.build(page_params)
    authorize @page

    if @page.save
      redirect_to @page, notice: "サービスを登録しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @page
  end

  def update
    authorize @page
    if @page.update(page_params)
      redirect_to @page, notice: "サービス情報を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @page
    @page.destroy
    redirect_to pages_path, notice: "サービスを削除しました。"
  end

  private

  def set_page
    @page = Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:name, :url)
  end
end
