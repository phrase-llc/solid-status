require "rails_helper"

RSpec.describe StatusPagePublishing::S3Storage do
  it "writes static HTML with its cache policy" do
    client = instance_double(Aws::S3::Client)
    storage = described_class.new(bucket: "status-pages", client: client)

    expect(client).to receive(:put_object).with(
      bucket: "status-pages",
      key: "status-pages/api/index.html",
      body: "<html></html>",
      content_type: "text/html; charset=utf-8",
      cache_control: "no-cache"
    )

    storage.write(
      key: "status-pages/api/index.html",
      body: "<html></html>",
      content_type: "text/html; charset=utf-8",
      cache_control: "no-cache"
    )
  end

  it "deletes the object when a status page is removed" do
    client = instance_double(Aws::S3::Client)
    storage = described_class.new(bucket: "status-pages", client: client)

    expect(client).to receive(:delete_object).with(bucket: "status-pages", key: "status-pages/api/index.html")

    storage.delete(key: "status-pages/api/index.html")
  end
end
