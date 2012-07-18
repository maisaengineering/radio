class MakeZeroDefaultForTimesListened < ActiveRecord::Migration
  def up
  	remove_column :playlists, :times_listened
  	add_column :playlists, :times_listened, :integer, :default => 0
  end

  def down
  end
end
