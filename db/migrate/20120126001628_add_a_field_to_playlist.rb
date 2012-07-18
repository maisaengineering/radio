class AddAFieldToPlaylist < ActiveRecord::Migration
  def change
  	add_column :playlists, :locked, :boolean # only admin can add songs
  	add_column :playlists, :times_listened, :integer # +1 when last Song.id is played
  end
end
