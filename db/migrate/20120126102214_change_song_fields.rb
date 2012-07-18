class ChangeSongFields < ActiveRecord::Migration
  def up
  	remove_column :songs, :amt_heard
  	remove_column :songs, :amt_havent_heard
  	remove_column :songs, :like_it
  	remove_column :songs, :dont_like_it
  end

  def down
  end
end
