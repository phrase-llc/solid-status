class RemoveMemberships < ActiveRecord::Migration[8.1]
  def change
    drop_table :memberships
  end
end
