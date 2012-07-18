class DropWidgetsColumn < ActiveRecord::Migration
  def up
  	remove_column :songs, :youtube_widget
  	remove_column :songs, :soundcloud_widget
  end

  def down
  end
end
