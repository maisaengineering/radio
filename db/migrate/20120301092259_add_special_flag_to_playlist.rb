class AddSpecialFlagToPlaylist < ActiveRecord::Migration
  def up
  	add_column :playlists, :special, :boolean, :default => false
  end
  def down
  end
end
