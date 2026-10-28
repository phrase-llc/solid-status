require "rails_helper"

require Rails.root.join("db/migrate/20260824120000_add_slug_to_status_pages")

RSpec.describe AddSlugToStatusPages do
  subject(:migration) { described_class.new }

  describe "legacy slug generation" do
    it "removes a trailing hyphen exposed by the 63-character limit" do
      legacy_url = "https://#{"a" * 62}-b.example.com"

      slug = migration.send(:legacy_slug, legacy_url)

      expect(slug).to eq("a" * 62)
      expect(slug).to match(/\A[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\z/)
    end

    it "falls back to the record id when normalization leaves no usable slug" do
      status_page = Struct.new(:id, :url).new(42, "https://---.example.com")
      relation = double(exists?: false)
      allow(described_class::MigrationStatusPage).to receive(:where).and_return(relation)
      allow(relation).to receive(:not).with(id: 42).and_return(relation)

      expect(migration.send(:unique_slug_for, status_page)).to eq("status-42")
    end

    it "keeps collision suffixes within the hostname label limit" do
      status_page = Struct.new(:id, :url).new(42, "https://#{"a" * 63}.example.com")
      relation = double
      allow(described_class::MigrationStatusPage).to receive(:where).and_return(relation)
      allow(relation).to receive(:not).with(id: 42).and_return(relation)
      allow(relation).to receive(:exists?).and_return(true, false)

      slug = migration.send(:unique_slug_for, status_page)

      expect(slug).to end_with("-2")
      expect(slug.length).to eq(63)
    end
  end
end
