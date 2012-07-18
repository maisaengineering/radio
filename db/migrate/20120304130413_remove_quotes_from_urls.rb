class RemoveQuotesFromUrls < ActiveRecord::Migration
  def up
  	Song.all.each do |song|
  		song.media_source_url = song.media_source_url.gsub("'", "")
  		song.save
  	end
  end

  def down
  end
end
