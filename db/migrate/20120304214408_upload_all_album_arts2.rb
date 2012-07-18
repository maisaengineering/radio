class UploadAllAlbumArts2 < ActiveRecord::Migration
	SC_CLIENT_ID = "48b5782b303b159c4dbdd05afab2fc1b"
	YOUTUBE_API_KEY = "AI39si6ds6O9MKU8bErE6GSReWLU23BUmRzyKqSqw-XkMgW2erXCquTS7Lq7V6pAS1VrIHGsd5VDFt1ZVs0sdZs1pULvgLcOEg"


  def up
	youtube_songs = Song.where("media_source_url LIKE '%youtube%'")
	soundcloud_songs = Song.where("media_source_url LIKE '%soundcloud%'")

	youtube_songs.each do |yt|
	  link = yt.media_source_url
	  client = YouTubeIt::Client.new(:dev_key => YOUTUBE_API_KEY)
	  token = CGI::parse(link.split("?")[1])["v"][0].strip
	  # ask toobie about track.
	  video = client.video_by(token)
	  url = video.thumbnails[1].url
	  image = HTTParty.get(url).parsed_response
	  file_name = File.basename(url)
	  ext = file_name.split('.')[1]
	  art_file = Tempfile.new([file_name, ".#{ext}"])
	  art_file.binmode
	  art_file.write(image)
	  album = Album.find_or_create_by_title(yt.title)
	  album.art = art_file
	  album.save!
	  yt.album = album
	end

	soundcloud_songs.each do |sc|
	  link = sc.media_source_url
	  resolve = HTTParty.get("http://api.soundcloud.com/resolve.json?url=#{link}&client_id=#{SC_CLIENT_ID}")
	  url = resolve["artwork_url"]
	  if url
	  image = HTTParty.get(url).parsed_response
	  file_name = File.basename(url)
	  ext = file_name.split('.')[1]
	  art_file = Tempfile.new([file_name, ".#{ext}"])
	  art_file.binmode
	  art_file.write(image)
	  album = Album.find_or_create_by_title(sc.title)
	  album.art = art_file
	  album.save!
	  sc.album = album
    end
	end
  end

  def down
  end
end
