json.extract! incident, :id, :page_id, :title, :started_at, :created_at, :updated_at
json.url incident_url(incident, format: :json)
