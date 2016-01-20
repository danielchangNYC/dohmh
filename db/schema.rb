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

ActiveRecord::Schema.define(version: 20160118015822) do

  create_table "establishments", force: :cascade do |t|
    t.string   "camis",               null: false
    t.string   "dba",                 null: false
    t.string   "boro",                null: false
    t.string   "zipcode",             null: false
    t.string   "phone"
    t.string   "cuisine_description", null: false
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "establishments", ["cuisine_description"], name: "index_establishments_on_cuisine_description"

  create_table "inspection_violations", force: :cascade do |t|
    t.integer  "inspection_id", null: false
    t.integer  "violation_id",  null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "inspection_violations", ["inspection_id"], name: "index_inspection_violations_on_inspection_id"
  add_index "inspection_violations", ["violation_id"], name: "index_inspection_violations_on_violation_id"

  create_table "inspections", force: :cascade do |t|
    t.integer  "establishment_id", null: false
    t.string   "action",           null: false
    t.datetime "inspection_date",  null: false
    t.integer  "score"
    t.string   "grade"
    t.datetime "grade_date"
    t.datetime "record_date"
    t.string   "inspection_type",  null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "inspections", ["establishment_id"], name: "index_inspections_on_establishment_id"

  create_table "violations", force: :cascade do |t|
    t.string   "code",        null: false
    t.string   "description"
    t.boolean  "critical",    null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "violations", ["code"], name: "index_violations_on_code"

end
