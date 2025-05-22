class StatusPages::Incidents::IncidentEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incident
  after_action :verify_authorized
  before_action :set_incident_entry, only: [:edit, :update, :destroy]

  def create
    @entry = @incident.incident_entries.build(incident_entry_params)
    authorize @entry

    if @entry.save
      respond_to do |format|
        format.turbo_stream do
          render :create, locals: { entry: @entry, incident: @incident }
        end
        format.html { redirect_to status_page_incident_path(@incident.status_page, @incident), notice: "更新を追加しました。" }
      end
    else
      @incident_entries = @incident.incident_entries.order(created_at: :asc)
      render "status_pages/incidents/show", status: :unprocessable_entity
    end
  end

  def edit
    authorize @incident_entry
    render partial: "status_pages/incidents/incident_entries/form", locals: { incident_entry: @incident_entry, incident: @incident, status_page: @incident.status_page }
  end

  def update
    authorize @incident_entry
    if @incident_entry.update(incident_entry_params)
      respond_to do |format|
        format.turbo_stream { render :update, locals: { incident_entry: @incident_entry, incident: @incident } }
        format.html { redirect_to status_page_incident_path(@incident.status_page, @incident), notice: "更新を更新しました。" }
      end
    else
      render partial: "status_pages/incidents/incident_entries/form", locals: { incident_entry: @incident_entry, incident: @incident, status_page: @incident.status_page }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @incident_entry
    @incident_entry.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove(@incident_entry)
      end
      format.html { redirect_to status_page_incident_path(@incident.status_page, @incident), notice: "更新を削除しました。" }
    end
  end

  private

  def set_incident_entry
    @incident_entry = IncidentEntry.find(params[:id])
  end

  def set_incident
    @incident = Incident.find(params[:incident_id])
  end

  def incident_entry_params
    params.require(:incident_entry).permit(:status, :body, :posted_at)
  end
end
