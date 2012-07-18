namespace :ishlist do

  task :prune_db => :environment do

    #Album.destroy_all("art_file_name is null")

    dead_link_ids = []

    SC_CLIENT_ID = "48b5782b303b159c4dbdd05afab2fc1b"
    YOUTUBE_API_KEY = "AI39si6ds6O9MKU8bErE6GSReWLU23BUmRzyKqSqw-XkMgW2erXCquTS7Lq7V6pAS1VrIHGsd5VDFt1ZVs0sdZs1pULvgLcOEg"


    youtube_songs = Song.where("media_source_url LIKE '%youtube%'") #.joins(:album).where("albums.art_file_name is null")
    soundcloud_songs = Song.where("media_source_url LIKE '%soundcloud%'") #.joins(:album).where("albums.art_file_name is null")

    youtube_songs.each do |yt|
      link = yt.media_source_url
      puts link
      client = YouTubeIt::Client.new(:dev_key => YOUTUBE_API_KEY)
      token = CGI::parse(link.split("?")[1])["v"][0].strip
      # ask toobie about track.
      video = client.video_by(token)
      unless video.state[:name] == "published"
        Rails.logger.info("nuked #{yt.id}")
        dead_link_ids << yt.id
        next
      end
      url = video.thumbnails[1].url
      if yt.album.art.nil? || yt.album.art.url == "/arts/original/missing.png"
        image = HTTParty.get(url).parsed_response
        file_name = File.basename(url)
        ext = file_name.split('.')[1]
        art_file = Tempfile.new([file_name, ".#{ext}"])
        art_file.binmode
        art_file.write(image)
        album = Album.find_or_create_by_title(yt.title)
        album.art = art_file
        album.save!
        yt.update_attribute :album_id, album.id
      end
    end

    soundcloud_songs.each do |sc|
      link = sc.media_source_url
      puts link
      resolve = HTTParty.get(URI.encode("http://api.soundcloud.com/resolve.json?url=#{link}&client_id=#{SC_CLIENT_ID}"))

      if resolve.parsed_response == {"errors"=> [{"error_message"=>"404 - Not Found"}]} || resolve == nil
        Rails.logger.info("nuked #{sc.id}")
        dead_link_ids << sc.id
        next
      end

      #sc.artist.update_attributes(:name => resolve['user']['username'])
      #sc.update_attributes(:title => resolve['title'])

      url = resolve["artwork_url"]
      if url
        if sc.album.art.nil? || sc.album.art.url == "/arts/original/missing.png"
          album = Album.find_or_create_by_title(sc.title)
          image = HTTParty.get(url).parsed_response
          file_name = File.basename(url)
          ext = file_name.split('.')[1]
          art_file = Tempfile.new([file_name, ".#{ext}"])
          art_file.binmode
          art_file.write(image)
          album.art = art_file
          album.save!
          sc.update_attribute :album_id, album.id
        end
      end



      #end
    end

    if dead_link_ids.count > 0
      Rails.logger.info("nuked: #{dead_link_ids.join(', ')}")
      Song.destroy_all(['id in (?)', dead_link_ids])
    end

  end

end