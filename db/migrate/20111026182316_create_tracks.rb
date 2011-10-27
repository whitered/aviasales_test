class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.references :origin
      t.references :destination
      t.datetime :departure
      t.datetime :arrival
      t.integer :transfers_number
      t.integer :transfers_minutes
      t.integer :price

      t.references :flight
      t.references :track1
      t.references :track2

      t.timestamps
    end

    add_index :tracks, :origin_id
    add_index :tracks, :destination_id
    add_index :tracks, :departure
    add_index :tracks, :arrival
  end
end
