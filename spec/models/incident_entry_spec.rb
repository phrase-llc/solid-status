require "rails_helper"

RSpec.describe IncidentEntry, type: :model do
  include ActiveJob::TestHelper

  self.use_transactional_tests = false

  after do
    IncidentEntry.delete_all
    Incident.delete_all
    StatusPage.delete_all
    Organization.delete_all
  end

  it "republishes its incident's status page after it is created" do
    status_page = create(:status_page)
    incident = Incident.create!(status_page: status_page, title: "API 障害", started_at: Time.current)
    clear_enqueued_jobs

    expect {
      described_class.create!(incident: incident, status: :investigating, body: "調査中です。", posted_at: Time.current)
    }.to have_enqueued_job(PublishStatusPageJob).with(status_page.id)
  end
end

RSpec.describe "incident entry cleanup", type: :model do
  include ActiveJob::TestHelper

  self.use_transactional_tests = false

  after do
    IncidentEntry.delete_all
    Incident.delete_all
    StatusPage.delete_all
    Organization.delete_all
  end

  it "does not fail when its incident is deleted" do
    status_page = create(:status_page)
    incident = Incident.create!(status_page: status_page, title: "API 障害", started_at: Time.current)
    entry = IncidentEntry.create!(incident: incident, status: :investigating, posted_at: Time.current)
    entry.reload
    clear_enqueued_jobs

    expect { incident.destroy! }.not_to raise_error
    expect(enqueued_jobs.map { |job| job["arguments"].first }).to include(status_page.id)
  end
end
