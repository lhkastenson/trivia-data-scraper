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

ActiveRecord::Schema[8.1].define(version: 2026_01_18_173603) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "artists", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "followers"
    t.jsonb "genres"
    t.string "name"
    t.integer "popularity"
    t.string "spotify_id"
    t.datetime "updated_at", null: false
    t.index ["popularity"], name: "index_artists_on_popularity"
    t.index ["spotify_id"], name: "index_artists_on_spotify_id", unique: true
  end

  create_table "before_afters", force: :cascade do |t|
    t.string "connecting_word", null: false
    t.datetime "created_at", null: false
    t.string "format", null: false
    t.text "full_phrase", null: false
    t.bigint "item_one_id", null: false
    t.string "item_one_type", null: false
    t.bigint "item_two_id", null: false
    t.string "item_two_type", null: false
    t.integer "quality_rating"
    t.string "status", default: "generated", null: false
    t.datetime "updated_at", null: false
    t.index ["item_one_type", "item_one_id"], name: "index_before_afters_on_item_one"
    t.index ["item_one_type", "item_one_id"], name: "index_before_afters_on_item_one_type_and_item_one_id"
    t.index ["item_two_type", "item_two_id"], name: "index_before_afters_on_item_two"
    t.index ["item_two_type", "item_two_id"], name: "index_before_afters_on_item_two_type_and_item_two_id"
    t.index ["quality_rating"], name: "index_before_afters_on_quality_rating"
    t.index ["status"], name: "index_before_afters_on_status"
  end

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

  create_table "songs", force: :cascade do |t|
    t.string "album_name"
    t.bigint "artist_id"
    t.datetime "created_at", null: false
    t.integer "popularity"
    t.date "release_date"
    t.string "spotify_id"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_songs_on_artist_id"
    t.index ["popularity"], name: "index_songs_on_popularity"
    t.index ["spotify_id"], name: "index_songs_on_spotify_id", unique: true
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

  add_foreign_key "songs", "artists"
end
