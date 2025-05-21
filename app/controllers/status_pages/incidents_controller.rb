class StatusPages::IncidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_status_page
  before_action :set_incident, only: %i[show edit update destroy]
  before_action :authorize_incident, only: %i[show edit update destroy]
  after_action :verify_policy_scoped, only: :index
  after_action :verify_authorized, except: %w[index new]

  def index
    @incidents = policy_scope(Incident)
  end

  def show; end

  def new
    @incident = Incident.new
    # authorize @incident
  end

  def create
    @incident = @status_page.incidents.build(incident_params)
    authorize @incident
    @incident.save
    respond_with @incident, location: [@status_page, @incident]

    # if @incident.save
    #   redirect_to [@status_page, @incident], notice: "Incident was successfully created."
    # else
    #   render :new, status: :unprocessable_entity
    # end
  end

  def edit; end

  def update
    if @incident.update(incident_params)
      redirect_to @incident, notice: "Incident was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @incident.destroy
    redirect_to incidents_url, notice: "Incident was successfully destroyed."
  end

  private

  def set_status_page
    @status_page = StatusPage.find(params[:status_page_id])
  end

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def authorize_incident
    authorize @incident
  end

  def incident_params
    params.require(:incident).permit(:title, :started_at)
  end
end
