require "rails_helper"

RSpec.describe "durable public page publication", type: :model do
  include ActiveJob::TestHelper

  let(:status_page) { create(:status_page, slug: "api") }
  let(:storage) { instance_double(StatusPagePublishing::LocalStorage, write: true, delete: true) }

  before { allow(StatusPagePublishing::Storage).to receive(:build).and_return(storage) }

  it "records publication in the business transaction and rolls back with it" do
    expect {
      StatusPage.transaction do
        create(:status_page)
        raise ActiveRecord::Rollback
      end
    }.not_to change(StatusPagePublication, :count)
  end

  it "does not allow a deleted page's slug to be claimed by another page" do
    status_page.destroy!
    replacement = build(:status_page, slug: "api")

    expect(replacement).not_to be_valid
    expect(replacement.errors[:slug]).to be_present
  end

  it "lets a page reclaim its own previous slug" do
    status_page.update!(slug: "api-v2")
    expect { status_page.update!(slug: "api") }.not_to raise_error
  end

  it "processes current state rather than deleting a reclaimed slug" do
    status_page.update!(slug: "api-v2")
    status_page.update!(slug: "api")

    expect(storage).to receive(:write).with(hash_including(key: "status-pages/api/index.html"))
    expect(storage).not_to receive(:delete)
    UnpublishStatusPageJob.perform_now("api")
  end

  it "keeps failed writes pending for reconciliation" do
    publication = StatusPagePublication.find_by!(slug: status_page.slug)
    allow(storage).to receive(:write).and_raise(IOError, "storage unavailable")

    expect { publication.process! }.to raise_error(IOError)
    expect(publication.reload).to be_pending
  end

  it "recovers committed requests without relying on their original queue jobs" do
    status_page
    clear_enqueued_jobs

    expect(storage).to receive(:write)
    ReconcileStatusPagePublicationsJob.perform_now
    expect(StatusPagePublication.find_by!(slug: "api")).not_to be_pending
  end

  it "ignores duplicate jobs after successfully publishing the latest content" do
    status_page.update!(name: "Latest content")

    expect(storage).to receive(:write).once.with(hash_including(body: include("Latest content")))
    2.times { PublishStatusPageJob.perform_now(status_page.id) }
  end

  it "preserves an unpublish request after page deletion" do
    status_page.destroy!

    expect(storage).to receive(:delete).with(key: "status-pages/api/index.html")
    ReconcileStatusPagePublicationsJob.perform_now
    expect(StatusPagePublication.find_by!(slug: "api")).not_to be_pending
  end
  it "rejects a different owner even if application validation is bypassed" do
    status_page.destroy!
    replacement = build(:status_page, slug: "api")

    expect { replacement.save!(validate: false) }.to raise_error(ActiveRecord::RecordInvalid)
    expect(StatusPage.where(id: replacement.id)).not_to exist
  end
  it "continues reconciling other pages when one storage operation fails" do
    status_page
    other_page = create(:status_page, slug: "other")
    error = Aws::S3::Errors::ServiceError.new(nil, "storage unavailable")
    allow(storage).to receive(:write).with(hash_including(key: "status-pages/api/index.html")).and_raise(error)
    expect(Rails.error).to receive(:report).with(error, handled: true)

    ReconcileStatusPagePublicationsJob.perform_now

    expect(StatusPagePublication.find_by!(slug: "api")).to be_pending
    expect(StatusPagePublication.find_by!(slug: other_page.slug)).not_to be_pending
  end
end
