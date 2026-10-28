require "rails_helper"

RSpec.describe UnpublishStatusPageJob, type: :job do
  it "removes the stored public page" do
    create(:status_page, slug: "api").destroy!
    publisher = instance_double(StatusPagePublishing::Publisher, unpublish: true)

    expect(StatusPagePublishing::Publisher).to receive(:new).with(nil).and_return(publisher)
    expect(publisher).to receive(:unpublish).with("api")

    described_class.perform_now("api")
  end
end
