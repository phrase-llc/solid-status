class CreateIncidentEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :incident_entries do |t|
      t.references :incident, null: false, foreign_key: true
      t.string :status, null: false, default: "investigating"
      t.text :body
      t.datetime :posted_at, null: false

      t.timestamps
    end
  end
end
