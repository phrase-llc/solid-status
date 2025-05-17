json.extract! status_page, :id, :name, :url, :organization_id, :created_at, :updated_at
json.url status_page_url(status_page, format: :json)
