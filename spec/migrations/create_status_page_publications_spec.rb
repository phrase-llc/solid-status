require "rails_helper"

require Rails.root.join("db/migrate/20260824130000_create_status_page_publications")

RSpec.describe CreateStatusPagePublications do
  it "backfills existing pages as pending reservations and can be rolled back" do
    status_page = create(:status_page)
    migration = described_class.new

    migration.migrate(:down)
    expect(ActiveRecord::Base.connection.table_exists?(:status_page_publications)).to be(false)
    migration.migrate(:up)
    StatusPagePublication.reset_column_information
    ActiveRecord::Base.connection.clear_cache!

    connection = ActiveRecord::Base.connection
    publication = connection.select_one("SELECT status_page_id, pending, created_at FROM status_page_publications WHERE slug = #{connection.quote(status_page.slug)}")
    expect(publication.fetch("status_page_id")).to eq(status_page.id)
    expect(publication.fetch("pending")).to be(true)
    expect(publication.fetch("created_at")).to be_present
  end
end
