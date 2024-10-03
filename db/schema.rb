# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_10_03_083659) do
  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "created_by"
    t.string "remarks"
    t.integer "parent_category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "level", default: 1
    t.integer "sort_order", default: 0
    t.index ["parent_category_id"], name: "index_categories_on_parent_category_id"
  end

  create_table "documents", force: :cascade do |t|
    t.string "title"
    t.string "document_name"
    t.string "description"
    t.string "document_file_name"
    t.string "extension"
    t.integer "document_size"
    t.string "document_type"
    t.string "keywords"
    t.string "document_guid"
    t.integer "parent_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_category_id"], name: "index_documents_on_parent_category_id"
  end

  add_foreign_key "categories", "categories", column: "parent_category_id"
  add_foreign_key "documents", "categories", column: "parent_category_id"
end
