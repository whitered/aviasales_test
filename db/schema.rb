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

ActiveRecord::Schema.define(:version => 20111026182316) do

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flights", :force => true do |t|
    t.integer  "origin_id"
    t.integer  "destination_id"
    t.datetime "departure"
    t.datetime "arrival"
    t.integer  "price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "flights", ["arrival"], :name => "index_flights_on_arrival"
  add_index "flights", ["departure"], :name => "index_flights_on_departure"
  add_index "flights", ["destination_id"], :name => "index_flights_on_destination_id"
  add_index "flights", ["origin_id"], :name => "index_flights_on_origin_id"

  create_table "tracks", :force => true do |t|
    t.integer  "origin_id"
    t.integer  "destination_id"
    t.datetime "departure"
    t.datetime "arrival"
    t.integer  "transfers_number"
    t.integer  "transfers_minutes"
    t.integer  "price"
    t.integer  "flight_id"
    t.integer  "track1_id"
    t.integer  "track2_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracks", ["arrival"], :name => "index_tracks_on_arrival"
  add_index "tracks", ["departure"], :name => "index_tracks_on_departure"
  add_index "tracks", ["destination_id"], :name => "index_tracks_on_destination_id"
  add_index "tracks", ["origin_id"], :name => "index_tracks_on_origin_id"

end
