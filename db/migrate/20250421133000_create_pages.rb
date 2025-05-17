class CreatePages < ActiveRecord::Migration[8.0]
  def change
    create_table :pages do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name, null: false
      t.string :url, null: false, default: ''

      t.timestamps
    end
  end
end
