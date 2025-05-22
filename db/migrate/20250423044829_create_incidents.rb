class CreateIncidents < ActiveRecord::Migration[8.0]
  def change
    create_table :incidents do |t|
      t.references :status_page, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :started_at, null: false
      t.datetime :ended_at

      t.timestamps
    end
  end
end
