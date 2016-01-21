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
    t.string   "camis",               limit: 255, null: false
    t.string   "dba",                 limit: 255, null: false
    t.string   "boro",                limit: 255, null: false
    t.string   "building",            limit: 255, null: false
    t.string   "street",              limit: 255, null: false
    t.string   "zipcode",             limit: 255, null: false
    t.string   "phone",               limit: 255
    t.string   "cuisine_description", limit: 255, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "establishments", ["cuisine_description"], name: "index_establishments_on_cuisine_description", using: :btree

  create_table "inspection_violations", force: :cascade do |t|
    t.integer  "inspection_id", limit: 4, null: false
    t.integer  "violation_id",  limit: 4, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "inspection_violations", ["inspection_id"], name: "index_inspection_violations_on_inspection_id", using: :btree
  add_index "inspection_violations", ["violation_id"], name: "index_inspection_violations_on_violation_id", using: :btree

  create_table "inspections", force: :cascade do |t|
    t.integer  "establishment_id", limit: 4,   null: false
    t.string   "action",           limit: 255, null: false
    t.datetime "inspection_date",              null: false
    t.integer  "score",            limit: 4
    t.string   "grade",            limit: 255
    t.datetime "grade_date"
    t.datetime "record_date"
    t.string   "inspection_type",  limit: 255, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "inspections", ["establishment_id"], name: "index_inspections_on_establishment_id", using: :btree

  create_table "violations", force: :cascade do |t|
    t.string   "code",        limit: 255, null: false
    t.string   "description", limit: 255
    t.boolean  "critical",                null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "violations", ["code"], name: "index_violations_on_code", using: :btree

end
