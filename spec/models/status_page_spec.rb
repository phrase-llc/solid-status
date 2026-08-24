require "rails_helper"

RSpec.describe StatusPage, type: :model do
  include ActiveJob::TestHelper

  self.use_transactional_tests = false

  after do
    IncidentEntry.delete_all
    Incident.delete_all
    StatusPage.delete_all
    Organization.delete_all
  end

  describe "public hostname" do
    subject(:status_page) { build(:status_page, slug: "api") }

    it "builds a hostname and URL from its slug" do
      expect(status_page.public_host).to eq("api.example.com")
      expect(status_page.public_url).to eq("https://api.example.com")
    end
  end

  describe "publishing" do
    it "enqueues publishing after creation" do
      expect { create(:status_page) }
        .to have_enqueued_job(PublishStatusPageJob)
        .with(an_instance_of(Integer))
    end

    it "enqueues removal after destruction" do
      status_page = create(:status_page, slug: "api")
      clear_enqueued_jobs

      expect { status_page.destroy! }
        .to have_enqueued_job(UnpublishStatusPageJob)
        .with("api")
    end

    it "publishes the new slug and removes the old static page after a slug change" do
      status_page = create(:status_page, slug: "api")
      clear_enqueued_jobs

      status_page.update!(slug: "api-v2")

      expect(enqueued_jobs).to include(a_hash_including("job_class" => "PublishStatusPageJob", "arguments" => [ status_page.id ]))
      expect(enqueued_jobs).to include(a_hash_including("job_class" => "UnpublishStatusPageJob", "arguments" => [ "api" ]))
    end
  end
end
