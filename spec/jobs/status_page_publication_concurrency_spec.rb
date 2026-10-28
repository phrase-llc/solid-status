require "rails_helper"
require "timeout"

RSpec.describe "publication worker concurrency", type: :job do
  self.use_transactional_tests = false

  after do
    @threads&.each { |thread| thread.kill if thread.alive? }
    StatusPagePublication.delete_all
    IncidentEntry.delete_all
    Incident.delete_all
    StatusPage.delete_all
    Organization.delete_all
  end

  it "serializes duplicate workers through storage completion and publishes subsequent edits" do
    status_page = create(:status_page, name: "Old content")
    entered = Queue.new
    release = Queue.new
    bodies = Queue.new
    storage = double("storage")
    allow(StatusPagePublishing::Storage).to receive(:build).and_return(storage)
    allow(storage).to receive(:write) do |**args|
      bodies << args.fetch(:body)
      if bodies.size == 1
        entered << true
        Timeout.timeout(10) { release.pop }
      end
    end

    @threads = [ Thread.new { PublishStatusPageJob.perform_now(status_page.id) } ]
    Timeout.timeout(10) { entered.pop }
    @threads << Thread.new { PublishStatusPageJob.perform_now(status_page.id) }

    expect(@threads.last.join(0.1)).to be_nil
    expect(bodies.size).to eq(1)
    release << true
    Timeout.timeout(10) { @threads.each(&:value) }
    expect(bodies.size).to eq(1)

    status_page.update!(name: "Latest content")
    PublishStatusPageJob.perform_now(status_page.id)
    expect(bodies.size).to eq(2)
    bodies.pop
    expect(bodies.pop).to include("Latest content")
  end
  it "retains an edit committed while an older publication is uploading" do
    status_page = create(:status_page, name: "Old content")
    entered = Queue.new
    release = Queue.new
    bodies = Queue.new
    storage = double("storage")
    allow(StatusPagePublishing::Storage).to receive(:build).and_return(storage)
    allow(storage).to receive(:write) do |**args|
      bodies << args.fetch(:body)
      if bodies.size == 1
        entered << true
        Timeout.timeout(10) { release.pop }
      end
    end

    @threads = [ Thread.new { PublishStatusPageJob.perform_now(status_page.id) } ]
    Timeout.timeout(10) { entered.pop }
    @threads << Thread.new { StatusPage.find(status_page.id).update!(name: "Latest content") }

    expect(@threads.last.join(0.1)).to be_nil
    release << true
    Timeout.timeout(10) { @threads.each(&:value) }
    expect(StatusPagePublication.find_by!(slug: status_page.slug)).to be_pending

    PublishStatusPageJob.perform_now(status_page.id)
    expect(bodies.size).to eq(2)
    expect(bodies.pop).to include("Old content")
    expect(bodies.pop).to include("Latest content")
    expect(StatusPagePublication.find_by!(slug: status_page.slug)).not_to be_pending
  end
end
