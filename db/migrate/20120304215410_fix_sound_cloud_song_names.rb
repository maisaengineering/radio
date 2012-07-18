class FixSoundCloudSongNames < ActiveRecord::Migration
	SC_CLIENT_ID = "48b5782b303b159c4dbdd05afab2fc1b"

  def up

  	soundcloud_songs = Song.where("media_source_url LIKE '%soundcloud%'")

	soundcloud_songs.each do |sc|
	  puts "doing #{sc.id}"
	  link = sc.media_source_url
	  begin
	  	resolve = HTTParty.get("http://api.soundcloud.com/resolve.json?url=#{link}&client_id=#{SC_CLIENT_ID}")
	  	sc.artist.update_attributes(:name => resolve['user']['username'])
	  	sc.update_attributes(:title => resolve['title'])
	  rescue
	  	puts "couldnt do #{sc.id}.. consider deleting?"
	  end
	end
  end

  def down
  end
end
