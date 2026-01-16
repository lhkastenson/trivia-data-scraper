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

ActiveRecord::Schema[8.1].define(version: 2026_01_16_051506) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "movies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "genres"
    t.text "overview"
    t.float "popularity"
    t.string "poster_path"
    t.bigint "revenue"
    t.string "title"
    t.integer "tmdb_id"
    t.datetime "updated_at", null: false
    t.float "vote_average"
    t.integer "vote_count"
    t.integer "year"
    t.index ["tmdb_id"], name: "index_movies_on_tmdb_id", unique: true
    t.index ["vote_count"], name: "index_movies_on_vote_count"
    t.index ["year"], name: "index_movies_on_year"
  end

  create_table "tv_shows", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "genres"
    t.text "overview"
    t.float "popularity"
    t.string "poster_path"
    t.string "title"
    t.integer "tmdb_id"
    t.datetime "updated_at", null: false
    t.float "vote_average"
    t.integer "vote_count"
    t.integer "year"
    t.index ["tmdb_id"], name: "index_tv_shows_on_tmdb_id", unique: true
    t.index ["vote_count"], name: "index_tv_shows_on_vote_count"
    t.index ["year"], name: "index_tv_shows_on_year"
  end
end
