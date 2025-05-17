class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :page, null: false, foreign_key: true
      t.string :role, null: false, default: "viewer"

      t.timestamps
    end

    add_index :memberships, [ :user_id, :page_id ], unique: true
  end
end
