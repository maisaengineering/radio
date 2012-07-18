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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120709095202) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",                       :null => false
    t.string   "resource_type",                     :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body",          :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :null => false
    t.string   "encrypted_password",                    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "albums", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "art_file_name"
    t.integer  "art_file_size"
    t.datetime "art_updated_at"
  end

  create_table "artists", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "email"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.text     "bio",        :limit => 16777215
  end

  create_table "artists_genres", :id => false, :force => true do |t|
    t.integer "artist_id"
    t.integer "genre_id"
  end

  create_table "authentications", :force => true do |t|
    t.string   "uid"
    t.string   "provider"
    t.string   "token"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comment_likes", :force => true do |t|
    t.string   "comment_id"
    t.string   "favorite_id"
    t.string   "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "song_id"
  end

  create_table "comment_on_activities", :force => true do |t|
    t.string   "comment_id"
    t.string   "favorite_id"
    t.string   "user_id"
    t.string   "activity_comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "song_id"
  end

  create_table "comments", :force => true do |t|
    t.integer  "song_id"
    t.text     "comment",    :limit => 16777215
    t.integer  "user_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",                       :default => 0
    t.integer  "attempts",                       :default => 0
    t.text     "handler",    :limit => 16777215
    t.text     "last_error", :limit => 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "fans", :force => true do |t|
    t.integer  "artist_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", :force => true do |t|
    t.integer  "song_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres_songs", :id => false, :force => true do |t|
    t.integer "genre_id"
    t.integer "song_id"
  end

  create_table "heard_its", :force => true do |t|
    t.integer  "song_id"
    t.integer  "user_id"
    t.boolean  "heard_it"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hookup_entries", :force => true do |t|
    t.string   "user_id"
    t.string   "entry_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", :force => true do |t|
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.string   "subject"
    t.text     "message",    :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlists", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked"
    t.integer  "times_listened",                  :default => 0
    t.boolean  "god_like",                        :default => false
    t.string   "station_name_image_file_name"
    t.integer  "station_name_image_file_size"
    t.string   "station_name_image_content_type"
    t.datetime "station_name_image_updated_at"
    t.boolean  "special",                         :default => false
  end

  create_table "playlists_songs", :id => false, :force => true do |t|
    t.integer "playlist_id"
    t.integer "song_id"
    t.integer "position"
  end

  create_table "preferences", :force => true do |t|
    t.string   "type"
    t.string   "setting"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message",    :limit => 16777215
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month"
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "ratings", :force => true do |t|
    t.integer  "song_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "recent_activities", :force => true do |t|
    t.string   "activity_type"
    t.string   "user_id"
    t.string   "song_id"
    t.string   "activity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "recommendations", :force => true do |t|
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.integer  "song_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "songs", :force => true do |t|
    t.string   "audio_file_name"
    t.integer  "audio_file_size"
    t.string   "audio_content_type"
    t.datetime "audio_updated_at"
    t.string   "title"
    t.integer  "artist_id"
    t.integer  "uploader_id"
    t.string   "explanation"
    t.integer  "length_in_seconds"
    t.string   "where_to_download"
    t.integer  "ish_rating"
    t.text     "lyrics",             :limit => 16777215
    t.boolean  "can_download"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "md5"
    t.integer  "album_id"
    t.string   "media_source_url"
    t.string   "download_link"
    t.integer  "download_count"
    t.integer  "share_count"
    t.integer  "play_count",                             :default => 0
  end

  create_table "system_settings", :force => true do |t|
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password",     :limit => 128,                         :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                              :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "username"
    t.string   "zip"
    t.string   "address"
    t.boolean  "sex"
    t.datetime "dob"
    t.string   "birthplace"
    t.string   "city"
    t.text     "bio",                    :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "admin",                                      :default => false
    t.string   "chat_token"
    t.string   "current_playlist"
    t.string   "handle"
    t.string   "photo_file_name"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "fb_profile_pic"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
