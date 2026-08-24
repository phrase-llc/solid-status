class AddSlugToStatusPages < ActiveRecord::Migration[8.1]
  class MigrationStatusPage < ActiveRecord::Base
    self.table_name = "status_pages"
  end

  def up
    add_column :status_pages, :slug, :string

    MigrationStatusPage.reset_column_information
    MigrationStatusPage.find_each do |status_page|
      status_page.update_columns(slug: unique_slug_for(status_page))
    end

    change_column_null :status_pages, :slug, false
    add_index :status_pages, :slug, unique: true
  end

  def down
    remove_index :status_pages, :slug
    remove_column :status_pages, :slug
  end

  private

  def unique_slug_for(status_page)
    base_slug = legacy_slug(status_page.url).presence || "status-#{status_page.id}"
    slug = base_slug
    suffix = 2

    while MigrationStatusPage.where.not(id: status_page.id).exists?(slug: slug)
      suffix_text = "-#{suffix}"
      slug = "#{base_slug.first(63 - suffix_text.length)}#{suffix_text}"
      suffix += 1
    end

    slug
  end

  def legacy_slug(url)
    host = url.to_s.sub(%r{\Ahttps?://}i, "").split("/").first
    slug = host.to_s.split(".").first.to_s.downcase.gsub(/[^a-z0-9-]/, "-").gsub(/\A-+|-+\z/, "")

    slug.first(63).presence
  end
end
