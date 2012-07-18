class AddSoundCloudAndYouTubeLinksToSong < ActiveRecord::Migration
  def up
  	add_column :songs, :youtube_widget, :text # link
 	add_column :songs, :soundcloud_widget, :text # widget
  end

  def down
   	remove_column :songs, :youtube_widget, :text # link
 	remove_column :songs, :soundcloud_widget, :text # widget	
  end
end
