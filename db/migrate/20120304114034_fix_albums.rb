class FixAlbums < ActiveRecord::Migration
  def up
	youtube_songs = Song.where("media_source_url LIKE '%youtube%'")
	soundcloud_songs = Song.where("media_source_url LIKE '%soundcloud%'")

	youtube_songs.each do |yt|
	  album = Album.find_or_create_by_title(yt.title)
	  yt.album = album
	  yt.save
	end

	soundcloud_songs.each do |sc|
	  album = Album.find_or_create_by_title(sc.title)
	  sc.album = album
	  sc.save
    end
  end

  def down
  end
end
