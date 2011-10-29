class AddFlightsToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :flight_ids, :string
  end
end
