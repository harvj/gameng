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

ActiveRecord::Schema.define(version: 2020_05_29_055457) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cards", force: :cascade do |t|
    t.integer "game_id"
    t.string "name"
    t.string "value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "color"
    t.string "icon_class"
    t.integer "name_sort"
    t.integer "value_sort"
    t.index ["game_id"], name: "index_cards_on_game_id"
  end

  create_table "game_sessions", force: :cascade do |t|
    t.integer "game_id"
    t.string "uid"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.string "state"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_game_sessions_on_game_id"
    t.index ["uid"], name: "index_game_sessions_on_uid", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["slug"], name: "index_games_on_slug", unique: true
  end

  create_table "players", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_session_id"
    t.boolean "moderator", default: false
    t.integer "score"
    t.index ["game_session_id", "user_id"], name: "index_players_on_game_session_id_and_user_id", unique: true
    t.index ["game_session_id"], name: "index_players_on_game_session_id"
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "session_cards", force: :cascade do |t|
    t.integer "session_deck_id"
    t.integer "card_id"
    t.integer "player_id"
    t.datetime "played_at"
    t.datetime "discarded_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "dealt_at"
    t.integer "game_session_id"
    t.index ["card_id"], name: "index_session_cards_on_card_id"
    t.index ["game_session_id", "session_deck_id"], name: "index_session_cards_on_game_session_id_and_session_deck_id"
    t.index ["game_session_id"], name: "index_session_cards_on_game_session_id"
    t.index ["player_id", "game_session_id"], name: "index_session_cards_on_player_id_and_game_session_id"
    t.index ["player_id", "session_deck_id"], name: "index_session_cards_on_player_id_and_session_deck_id"
    t.index ["player_id"], name: "index_session_cards_on_player_id"
    t.index ["session_deck_id"], name: "index_session_cards_on_session_deck_id"
  end

  create_table "session_decks", force: :cascade do |t|
    t.integer "game_session_id"
    t.string "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_session_id", "slug"], name: "index_session_decks_on_game_session_id_and_slug", unique: true
    t.index ["game_session_id"], name: "index_session_decks_on_game_session_id"
  end

  create_table "session_frames", force: :cascade do |t|
    t.integer "game_session_id"
    t.string "action"
    t.integer "active_player_id"
    t.integer "affected_played_id"
    t.integer "value"
    t.string "result"
    t.integer "subject_id"
    t.string "subject_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["action"], name: "index_session_frames_on_action"
    t.index ["active_player_id"], name: "index_session_frames_on_active_player_id"
    t.index ["affected_played_id"], name: "index_session_frames_on_affected_played_id"
    t.index ["game_session_id", "action"], name: "index_session_frames_on_game_session_id_and_action"
    t.index ["game_session_id"], name: "index_session_frames_on_game_session_id"
    t.index ["subject_id", "subject_type"], name: "index_session_frames_on_subject_id_and_subject_type"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

end
