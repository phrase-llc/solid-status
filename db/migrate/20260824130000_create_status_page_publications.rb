class CreateStatusPagePublications < ActiveRecord::Migration[8.1]
  def up
    create_table :status_page_publications do |t|
      t.string :slug, null: false
      t.bigint :status_page_id, null: false
      t.boolean :pending, null: false, default: true

      t.timestamps
    end

    add_index :status_page_publications, :slug, unique: true
    add_index :status_page_publications, [ :status_page_id, :id ], where: "pending = true", name: "index_status_page_publications_pending"

    execute <<~SQL
      INSERT INTO status_page_publications (slug, status_page_id, pending, created_at, updated_at)
      SELECT slug, id, TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
      FROM status_pages
    SQL
  end
  def down
    drop_table :status_page_publications
  end
end
