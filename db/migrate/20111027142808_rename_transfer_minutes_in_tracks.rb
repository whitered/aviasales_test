class RenameTransferMinutesInTracks < ActiveRecord::Migration

  def change
    rename_column :tracks, :transfers_minutes, :transfer_minutes
  end
end
