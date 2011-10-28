class AddIndexOnTransfersNumberToTracks < ActiveRecord::Migration
  def change
    add_index :tracks, :transfers_number
  end
end
