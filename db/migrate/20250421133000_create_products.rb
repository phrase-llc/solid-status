class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :domain, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
