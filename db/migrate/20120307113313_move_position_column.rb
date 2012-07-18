class MovePositionColumn < ActiveRecord::Migration
  def up
    remove_column :songs, :position
    add_column :playlists_songs, :position, :integer
  end

  def down
  end
end
