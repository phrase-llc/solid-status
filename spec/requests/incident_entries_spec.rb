require "rails_helper"

RSpec.describe "/status_pages/:status_page_id/incidents/:incident_id/incident_entries", type: :request do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, organization: organization) }
  let(:status_page) { create(:status_page, organization: organization) }
  let(:incident) { Incident.create!(status_page: status_page, title: "First incident", started_at: Time.current) }
  let(:other_incident) { Incident.create!(status_page: status_page, title: "Second incident", started_at: Time.current) }
  let(:other_entry) do
    IncidentEntry.create!(incident: other_incident, status: :investigating, body: "Initial update", posted_at: Time.current)
  end

  before do
    sign_in admin
  end

  it "does not update an entry that belongs to a different incident" do
    patch status_page_incident_incident_entry_path(status_page, incident, other_entry), params: {
      incident_entry: { status: "resolved", body: "Unexpected update", posted_at: Time.current }
    }

    expect(response).to have_http_status(:not_found)
    expect(other_entry.reload).to have_attributes(status: "investigating", body: "Initial update")
  end
end
