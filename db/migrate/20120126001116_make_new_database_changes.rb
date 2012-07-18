class MakeNewDatabaseChanges < ActiveRecord::Migration
  def up
  	add_column :songs, :amt_heard, :integer
  	add_column :songs, :amt_havent_heard, :integer
  	add_column :songs, :like_it, :integer
  	add_column :songs, :dont_like_it, :integer
  	
  end

  def down
  end
end
