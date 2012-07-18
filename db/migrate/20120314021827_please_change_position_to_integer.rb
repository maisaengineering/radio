class PleaseChangePositionToInteger < ActiveRecord::Migration
  def up
    change_column :playlists_songs, :position, :integer
  end

  def down
  end
end
