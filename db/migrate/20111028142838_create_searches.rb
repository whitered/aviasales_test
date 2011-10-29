class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.references :origin
      t.references :destination
      t.datetime :departure_from
      t.datetime :departure_to
      t.datetime :arrival_from
      t.datetime :arrival_to
      t.integer :max_price
      t.integer :max_transfers
      t.integer :max_track_minutes

      t.timestamps
    end
  end
end
