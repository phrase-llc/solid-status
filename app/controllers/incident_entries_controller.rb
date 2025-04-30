class IncidentEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incident
  after_action :verify_authorized

  def create
    @entry = @incident.incident_entries.build(incident_entry_params)
    authorize @entry

    if @entry.save
      redirect_to @incident, notice: "更新を追加しました。"
    else
      @incident_entries = @incident.incident_entries.order(created_at: :asc)
      render "incidents/show", status: :unprocessable_entity
    end
  end

  private

  def set_incident
    @incident = Incident.find(params[:incident_id])
  end

  def incident_entry_params
    params.require(:incident_entry).permit(:status, :body)
  end
end
