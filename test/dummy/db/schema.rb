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

ActiveRecord::Schema[7.1].define(version: 2024_05_01_131248) do
  create_table "code_giant_users", force: :cascade do |t|
    t.string "graphql_id"
    t.string "name"
    t.string "username"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graphql_id"], name: "index_code_giant_users_on_graphql_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "issue_id"
    t.string "author"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "field_mappings", force: :cascade do |t|
    t.json "mapping", default: {}, null: false
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_field_mappings_on_project_id"
  end

  create_table "histories", force: :cascade do |t|
    t.string "author"
    t.datetime "created_at"
    t.json "items", default: {}, null: false
    t.integer "issue_id", null: false
    t.index ["issue_id"], name: "index_histories_on_issue_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "key"
    t.string "summary"
    t.text "description"
    t.string "status"
    t.string "creator_display_name"
    t.string "reporter_display_name"
    t.datetime "jira_created_at"
    t.datetime "jira_updated_at"
    t.string "jira_project_id"
    t.string "priority"
    t.string "issue_type"
    t.integer "jira_issue_id"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "jira_user_id"
    t.integer "code_giant_user_id"
    t.integer "code_giant_task_id"
    t.integer "estimated_time"
    t.integer "actual_time"
    t.datetime "due_date"
    t.index ["code_giant_task_id"], name: "index_issues_on_code_giant_task_id"
    t.index ["jira_issue_id"], name: "index_issues_on_jira_issue_id", unique: true
    t.index ["project_id"], name: "index_issues_on_project_id"
  end

  create_table "jira_users", force: :cascade do |t|
    t.string "account_id"
    t.string "display_name"
    t.string "avatar_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "project_id"
    t.string "project_key"
    t.string "name"
    t.string "url"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "code_giant_project_id"
    t.string "prefix"
    t.string "codegiant_title"
    t.index ["code_giant_project_id"], name: "index_projects_on_code_giant_project_id"
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "name"
    t.string "jira_uid"
    t.string "jira_access_token"
    t.string "jira_refresh_token"
    t.datetime "token_expires_at"
    t.string "jira_site_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jira_site_id"
  end

  add_foreign_key "comments", "issues"
  add_foreign_key "field_mappings", "projects"
  add_foreign_key "histories", "issues"
  add_foreign_key "issues", "projects"
  add_foreign_key "projects", "users"
end
