class GodLikePlaylists < ActiveRecord::Migration
  def up
    add_column :playlists, :god_like, :boolean, :default => false
  end

  def down
    remove_column :playlists, :god_like
  end
end

