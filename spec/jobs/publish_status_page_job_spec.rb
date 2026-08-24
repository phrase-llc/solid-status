require "rails_helper"

RSpec.describe PublishStatusPageJob, type: :job do
  it "renders and stores the current status page" do
    status_page = create(:status_page)
    publisher = instance_double(StatusPagePublishing::Publisher, publish: true)

    expect(StatusPagePublishing::Publisher).to receive(:new).with(status_page).and_return(publisher)
    expect(publisher).to receive(:publish)

    described_class.perform_now(status_page.id)
  end

  it "does nothing when the page was deleted before the job ran" do
    expect { described_class.perform_now(-1) }.not_to raise_error
  end
end
