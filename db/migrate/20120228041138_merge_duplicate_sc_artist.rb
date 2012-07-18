class MergeDuplicateScArtist < ActiveRecord::Migration
  def up
  	soundcloud_songs = Song.where("soundcloud_widget IS NOT NULL").all
  	soundcloud_songs.each do |sc|
  		link = sc.media_source_url
  		parsed_link = link.split("/")
        title = parsed_link[parsed_link.length - 1].gsub("-", " ").split(" ").each{|word| word.capitalize!}.join(" ")
        artist = parsed_link[parsed_link.length - 2].gsub("-", " ").split(" ").each{|word| word.capitalize!}.join(" ")
        Artist.destroy_all(:name => artist)
        artist = Artist.create(:name => artist)
        sc.artist = artist
        sc.save
  	end
  end

  def down
  end
end
