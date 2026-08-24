require "rails_helper"

RSpec.describe StatusPagePublishing::Publisher do
  describe "#publish" do
    it "stores an escaped static HTML representation of the status page" do
      status_page = create(:status_page, name: "API Status", slug: "api")
      incident = Incident.create!(status_page: status_page, title: "API 障害", started_at: Time.zone.parse("2026-08-24 10:00"))
      IncidentEntry.create!(incident: incident, status: :investigating, body: "<script>alert('xss')</script>", posted_at: Time.zone.parse("2026-08-24 10:05"))
      storage = instance_double(StatusPagePublishing::LocalStorage)

      expect(storage).to receive(:write) do |key:, body:, content_type:, cache_control:|
        expect(key).to eq("status-pages/api/index.html")
        expect(content_type).to eq("text/html; charset=utf-8")
        expect(cache_control).to eq("public, max-age=60, s-maxage=60, stale-while-revalidate=60, stale-if-error=86400")
        expect(body).to include("API Status", "API 障害", "調査中")
        expect(body).to include("&lt;script&gt;alert('xss')&lt;/script&gt;")
        expect(body).not_to include("<script>")
      end

      described_class.new(status_page, storage: storage).publish
    end
  end

  describe "#unpublish" do
    it "deletes the static page for the slug" do
      storage = instance_double(StatusPagePublishing::LocalStorage)
      expect(storage).to receive(:delete).with(key: "status-pages/api/index.html")

      described_class.new(nil, storage: storage).unpublish("api")
    end
  end
end
