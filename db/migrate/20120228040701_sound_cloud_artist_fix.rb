class SoundCloudArtistFix < ActiveRecord::Migration
  def up
  	client_id = "48b5782b303b159c4dbdd05afab2fc1b"
  	soundcloud_songs = Song.where("soundcloud_widget IS NOT NULL").all
  	soundcloud_songs.each do |sc|
  		link = sc.media_source_url
  		parsed_link = link.split("/")
        title = parsed_link[parsed_link.length - 1].gsub("-", " ").split(" ").each{|word| word.capitalize!}.join(" ")
        artist = parsed_link[parsed_link.length - 2].gsub("-", " ").split(" ").each{|word| word.capitalize!}.join(" ")
        sc.artist.update_attributes(:name => artist)
  	end
  end

  def down
  end
end
