class CreateMediaSourceUrlForAllSongsAndDropWidgetHtmLs < ActiveRecord::Migration
  def up
  	# add all media source URLs existing
  	soundcloud_songs = Song.where("soundcloud_widget IS NOT NULL").all
  	youtube_songs = Song.where("youtube_widget IS NOT NULL").all
  	soundcloud_songs.each do |sc| link = sc.soundcloud_widget.match(/https?:\/\/[\S]+/).to_s.gsub("'", ""); puts "#{link}" ; sc.update_attributes!(:media_source_url => link) end
   	youtube_songs.each do |yt| link = 'http://www.youtube.com/watch?v=' + yt.youtube_widget.match(/initialVideo: .+/).to_s.split('"')[1]; puts "#{link}" ; yt.update_attributes!(:media_source_url => link) end
  
   	# drop _widget
   	remove_column :songs, :youtube_widget
   	remove_column :songs, :soundcloud_widget
  end

  def down
   	# add_column :songs, :youtube_widget, :text
   	# add_column :songs, :soundcloud_widget, :text
  end
end
