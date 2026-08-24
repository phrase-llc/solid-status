require "rails_helper"

RSpec.describe Incident, type: :model do
  include ActiveJob::TestHelper

  self.use_transactional_tests = false

  after do
    IncidentEntry.delete_all
    Incident.delete_all
    StatusPage.delete_all
    Organization.delete_all
  end

  it "republishes its status page after it is created" do
    status_page = create(:status_page)
    clear_enqueued_jobs

    expect {
      described_class.create!(status_page: status_page, title: "API 障害", started_at: Time.current)
    }.to have_enqueued_job(PublishStatusPageJob).with(status_page.id)
  end
end
