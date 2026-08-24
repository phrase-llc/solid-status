json.extract! status_page, :id, :name, :slug, :organization_id, :created_at, :updated_at
json.internal_url status_page_url(status_page, format: :json)
json.public_url status_page.public_url
