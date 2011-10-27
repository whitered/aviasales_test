class RemoveTransferMinutesFromTracks < ActiveRecord::Migration

  def change
    remove_column :tracks, :transfer_minutes
  end
end
