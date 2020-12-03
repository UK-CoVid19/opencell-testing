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

ActiveRecord::Schema.define(version: 2020_12_03_165607) do

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

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "api_key_hash"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "notify"
    t.string "url"
    t.bigint "labgroup_id", null: false
    t.index ["api_key_hash"], name: "index_clients_on_api_key_hash"
    t.index ["labgroup_id"], name: "index_clients_on_labgroup_id"
    t.index ["name", "labgroup_id"], name: "index_clients_on_name_and_labgroup_id", unique: true
    t.index ["name"], name: "index_clients_on_name"
  end

  create_table "headers", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.bigint "client_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["client_id"], name: "index_headers_on_client_id"
    t.index ["key", "client_id"], name: "index_headers_on_key_and_client_id", unique: true
  end

  create_table "labgroups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "labgroups_users", id: false, force: :cascade do |t|
    t.bigint "labgroup_id", null: false
    t.bigint "user_id", null: false
    t.index ["labgroup_id", "user_id"], name: "index_labgroups_users_on_labgroup_id_and_user_id"
    t.index ["user_id", "labgroup_id"], name: "index_labgroups_users_on_user_id_and_labgroup_id"
  end

  create_table "labs", force: :cascade do |t|
    t.string "name"
    t.bigint "labgroup_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["labgroup_id"], name: "index_labs_on_labgroup_id"
  end

  create_table "plates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state", default: 0
    t.string "uid"
    t.bigint "lab_id", null: false
    t.index ["lab_id"], name: "index_plates_on_lab_id"
    t.index ["state"], name: "index_plates_on_state"
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

  create_table "reruns", force: :cascade do |t|
    t.bigint "sample_id"
    t.bigint "retest_id"
    t.string "reason"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["retest_id"], name: "index_reruns_on_retest_id", unique: true
    t.index ["sample_id"], name: "index_reruns_on_sample_id", unique: true
  end

  create_table "samples", force: :cascade do |t|
    t.integer "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "well_id"
    t.bigint "plate_id"
    t.string "uid"
    t.bigint "client_id"
    t.boolean "control", default: false
    t.boolean "is_retest", default: false, null: false
    t.index ["client_id"], name: "index_samples_on_client_id"
    t.index ["plate_id"], name: "index_samples_on_plate_id"
    t.index ["state"], name: "index_samples_on_state"
    t.index ["uid", "is_retest", "client_id"], name: "index_samples_on_uid_and_is_retest_and_client_id", unique: true
    t.index ["uid"], name: "index_samples_on_uid"
  end

  create_table "security_questions", force: :cascade do |t|
    t.string "locale", null: false
    t.string "name", null: false
  end

  create_table "test_results", force: :cascade do |t|
    t.bigint "test_id"
    t.bigint "well_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "state"
    t.text "comment"
    t.index ["test_id"], name: "index_test_results_on_test_id"
    t.index ["well_id"], name: "index_test_results_on_well_id"
  end

  create_table "tests", force: :cascade do |t|
    t.bigint "plate_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "comment"
    t.index ["plate_id"], name: "index_tests_on_plate_id", unique: true
    t.index ["user_id"], name: "index_tests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.datetime "locked_at"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.string "unique_session_id"
    t.bigint "security_question_id"
    t.string "security_question_answer"
    t.index ["api_key"], name: "index_users_on_api_key"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["security_question_id"], name: "index_users_on_security_question_id"
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
  add_foreign_key "clients", "labgroups"
  add_foreign_key "headers", "clients"
  add_foreign_key "labs", "labgroups"
  add_foreign_key "plates", "labs"
  add_foreign_key "records", "samples"
  add_foreign_key "records", "users"
  add_foreign_key "reruns", "samples"
  add_foreign_key "samples", "clients"
  add_foreign_key "samples", "plates"
  add_foreign_key "samples", "wells"
  add_foreign_key "test_results", "tests"
  add_foreign_key "test_results", "wells"
  add_foreign_key "tests", "plates"
  add_foreign_key "tests", "users"
  add_foreign_key "users", "security_questions"
  add_foreign_key "wells", "plates"
  add_foreign_key "wells", "samples"
end
