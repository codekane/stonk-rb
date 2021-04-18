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

ActiveRecord::Schema.define(version: 2021_04_17_234120) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "search_stonks", id: false, force: :cascade do |t|
    t.bigint "stonk_id"
    t.bigint "search_id"
    t.integer "count"
    t.index ["search_id"], name: "index_search_stonks_on_search_id"
    t.index ["stonk_id"], name: "index_search_stonks_on_stonk_id"
  end

  create_table "searches", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stonks", force: :cascade do |t|
    t.string "symbol"
  end

end
