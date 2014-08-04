# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140726011350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "evaluations", force: true do |t|
    t.integer  "advisor_id"
    t.integer  "student_id"
    t.integer  "project_id"
    t.text     "comments",      default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "submission_id"
  end

  add_index "evaluations", ["advisor_id"], name: "index_evaluations_on_advisor_id", using: :btree
  add_index "evaluations", ["student_id", "project_id"], name: "index_evaluations_on_student_id_and_project_id", unique: true, using: :btree

  create_table "messages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content",    default: "", null: false
    t.string   "sender",     default: "", null: false
    t.string   "recipient",  default: "", null: false
  end

  create_table "projects", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                  default: "",        null: false
    t.integer  "advisor_id"
    t.datetime "deadline"
    t.text     "description",           default: "",        null: false
    t.string   "status",                default: "pending", null: false
    t.text     "expected_deliverables", default: "",        null: false
    t.text     "prerequisites",         default: "",        null: false
    t.text     "related_work",          default: "",        null: false
    t.integer  "quarter_id"
    t.boolean  "cloned",                default: false,     null: false
  end

  add_index "projects", ["advisor_id"], name: "index_projects_on_advisor_id", using: :btree
  add_index "projects", ["name", "quarter_id"], name: "index_projects_on_name_and_quarter_id", unique: true, using: :btree

  create_table "quarters", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "year"
    t.string   "season",     default: "", null: false
    t.boolean  "current"
  end

  create_table "submissions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "student_id"
    t.text     "information",         default: "",        null: false
    t.integer  "project_id"
    t.string   "status",              default: "pending", null: false
    t.text     "qualifications",      default: "",        null: false
    t.text     "courses",             default: "",        null: false
    t.string   "resume_file_name"
    t.string   "resume_content_type"
    t.integer  "resume_file_size"
    t.datetime "resume_updated_at"
  end

  add_index "submissions", ["student_id", "project_id"], name: "index_submissions_on_student_id_and_project_id", unique: true, using: :btree
  add_index "submissions", ["student_id"], name: "index_submissions_on_student_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "student",                default: true,  null: false
    t.boolean  "advisor",                default: false, null: false
    t.boolean  "admin",                  default: false, null: false
    t.string   "first_name",             default: "",    null: false
    t.string   "last_name",              default: "",    null: false
    t.string   "affiliation",            default: "",    null: false
    t.string   "department",             default: "",    null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
