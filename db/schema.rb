create_table "users", force: :cascade do |t|
  t.string "first_name", null: false, default: ""
  t.string "last_name", null: false, default: ""
  t.string "display_name", null: false, default: ""
  t.string "email", null: false, default: ""
  t.string "encrypted_password", null: false, default: ""
  # ...existing columns...
end
