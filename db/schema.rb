# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_08_06_103227) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "plates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0
    t.string "uid"
    t.index ["uid"], name: "index_plates_on_uid", unique: true
  end

  create_table "records", force: :cascade do |t|
    t.bigint "sample_id"
    t.string "note"
    t.integer "state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["sample_id"], name: "index_records_on_sample_id"
    t.index ["user_id"], name: "index_records_on_user_id"
  end

  create_table "samples", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "well_id"
    t.bigint "plate_id"
    t.string "uid"
    t.index ["plate_id"], name: "index_samples_on_plate_id"
    t.index ["uid"], name: "index_samples_on_uid", unique: true
    t.index ["user_id"], name: "index_samples_on_user_id"
  end

  create_table "test_results", force: :cascade do |t|
    t.bigint "test_id"
    t.bigint "well_id"
    t.float "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_id"], name: "index_test_results_on_test_id"
    t.index ["well_id"], name: "index_test_results_on_well_id"
  end

  create_table "tests", force: :cascade do |t|
    t.bigint "plate_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plate_id"], name: "index_tests_on_plate_id"
    t.index ["user_id"], name: "index_tests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.date "dob"
    t.string "telno"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role", default: 0, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "api_key"
    t.index ["api_key"], name: "index_users_on_api_key"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wells", force: :cascade do |t|
    t.string "row"
    t.integer "column"
    t.bigint "plate_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sample_id"
    t.index ["plate_id"], name: "index_wells_on_plate_id"
    t.index ["row", "column", "plate_id"], name: "index_wells_on_row_and_column_and_plate_id", unique: true
    t.index ["sample_id"], name: "index_wells_on_sample_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "records", "samples"
  add_foreign_key "records", "users"
  add_foreign_key "samples", "plates"
  add_foreign_key "samples", "users"
  add_foreign_key "samples", "wells"
  add_foreign_key "test_results", "tests"
  add_foreign_key "test_results", "wells"
  add_foreign_key "tests", "plates"
  add_foreign_key "tests", "users"
  add_foreign_key "wells", "plates"
  add_foreign_key "wells", "samples"
end
