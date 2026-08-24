class StatusPages::IncidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status_page
  before_action :set_incident, only: %i[show edit update destroy]
  before_action :authorize_incident, only: %i[show edit update destroy]

  def index
    authorize @status_page, :show?
    @incidents = policy_scope(@status_page.incidents).order(created_at: :desc)
  end

  def show; end

  def new
    @incident = @status_page.incidents.build
    authorize @incident
  end

  def create
    @incident = @status_page.incidents.build(incident_params)
    authorize @incident
    @incident.save
    respond_with @incident, location: [ @status_page, @incident ]
  end

  def edit; end

  def update
    if @incident.update(incident_params)
      redirect_to [ @status_page, @incident ], notice: "Incident was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @incident.destroy
    redirect_to status_page_incidents_url(@status_page), notice: "Incident was successfully destroyed."
  end

  private

  def set_status_page
    @status_page = StatusPage.find(params[:status_page_id])
  end

  def set_incident
    @incident = @status_page.incidents.find(params[:id])
  end

  def authorize_incident
    authorize @incident
  end

  def incident_params
    params.require(:incident).permit(:title, :started_at, :ended_at)
  end
end
