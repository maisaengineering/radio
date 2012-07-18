ActiveAdmin.register Song do

  SC_CLIENT_ID = "48b5782b303b159c4dbdd05afab2fc1b"
  YOUTUBE_API_KEY = "AI39si6ds6O9MKU8bErE6GSReWLU23BUmRzyKqSqw-XkMgW2erXCquTS7Lq7V6pAS1VrIHGsd5VDFt1ZVs0sdZs1pULvgLcOEg"

  action_item do
    link_to "Song Uploader (multi)", song_uploader_admin_songs_path
  end

  collection_action :new do
    redirect_to :action => :share_audio
  end

  collection_action :share_audio, :method => :get do

  end

  collection_action :add_links, :method => :post do
    links = params[:links][0]
    failed = 0

    links.each_line do |link|
        puts link
        if link.match(/youtube/)

          client = YouTubeIt::Client.new(:dev_key => YOUTUBE_API_KEY)

          token = CGI::parse(link.split("?")[1])["v"][0].strip

          video = client.video_by(token)
          if video.state[:name] == "published"
            url = video.thumbnails[1].url
            image = HTTParty.get(url).parsed_response
            file_name = File.basename(url)
            ext = file_name.split('.')[1]
            art_file = Tempfile.new([file_name, ".#{ext}"])
            art_file.binmode
            art_file.write(image)
            album = Album.find_or_create_by_title(video.title)
            album.art = art_file
            album.save!
            begin
              @song = Song.create!(:title => video.title) do |song|
                song.artist = Artist.find_or_create_by_name(video.author.name)
                song.uploader_id = current_user.id
                song.download_link = link
                song.media_source_url = link
                song.album = album
              end
            rescue
              failed += 1
            end
          else
            flash[:notice] = "One or more links were rejected because of embedding disabled by request."
            failed += 1
          end
        elsif link.match(/soundcloud/)
          resolve = HTTParty.get(URI.encode("http://api.soundcloud.com/resolve.json?url=#{link}&client_id=#{SC_CLIENT_ID}"))

          if resolve.parsed_response == {"errors"=> [{"error_message"=>"404 - Not Found"}]} || resolve == nil
            failed += 1
            next
          end

          parsed_link = link.split("/")
          title = resolve['title']
          artist = resolve['user']['username']

          url = resolve["artwork_url"]
          if url
            image = HTTParty.get(url).parsed_response
            file_name = File.basename(url)
            ext = file_name.split('.')[1]
            art_file = Tempfile.new([file_name, ".#{ext}"])
            art_file.binmode
            art_file.write(image)
            album = Album.find_or_create_by_title(title)
            album.art = art_file
            album.save!
          end

          begin
            @song = Song.create!(:title => title) do |song|
              song.artist = Artist.find_or_create_by_name(artist)
              song.uploader_id = current_user.id
              song.download_link = resolve["download_url"]
              song.media_source_url = link
              song.album = album
              song.save
            end
          rescue
            failed += 1
          end
        end

    end
    flash[:notice] ||= "Links parsed. #{failed} failed."
    redirect_to share_audio_admin_songs_path
  end

  collection_action :song_uploader, :method => :get do

  end

  collection_action :upload_songs, :method => :post do
    audio = params[:song][:audio]
    mp3_info = Mp3Info.new(audio.path)
    song = Song.new

    artist = Artist.find_or_create_by_name(mp3_info.tag.artist)
    song.artist = artist
    song.title = mp3_info.tag.title

    picture = mp3_info.tag2["APIC"]
    if picture
      art = parse_id3_apic(picture)
      file_name = params[:Filename].split(".")[0]
      ext = strip_null(art[1].split('/')[1])
      art_file = Tempfile.new([file_name, ".#{ext}"])
      art_file.binmode
      art_file.write(art[0])
      album = Album.find_or_create_by_title(mp3_info.tag.album)
      album.art = art_file
      album.save!
      song.album = album
    end

    song.uploader_id = current_user.id if current_user
    song.length_in_seconds = mp3_info.length.to_i
    song.md5 = Digest::MD5.file(params[:song][:audio].path).to_s
    genre = Genre.find_or_create_by_name(mp3_info.tag2["TCON"])
    song.genres << genre
    artist.genres << genre

    begin
      echonest = Echonest().track.profile(:md5 => song.md5)
      Rails.logger.info(echonest)
      if song.title.blank?
        song.title = echonest.body.track.title
      end
      if song.artist.nil?
        song.title = Artist.find_or_create_by_name(echonest.body.track.artist)
      end
    rescue Echonest::Api::Error
      # do nothing
    end

    params[:song][:audio].content_type = MIME::Types.type_for(params[:song][:audio].original_filename).to_s
    song.audio = params[:song][:audio]
    song.download_link = URI.encode('http://ishlist.s3.amazonaws.com' + song.audio.path)
    song.save


    render :text => [song.artist, song.title, song.convert_seconds_to_time].join(" - ")
  end

  collection_action :search, :method => :get do
    #options = {
    #  :type => params[:type] # could be title, artist, or referrer (referrer not implemented)
    #}
    @songs_by_title = Song.admin_search(params[:query], {:type => 'title'})
    @songs_by_artist = Song.admin_search(params[:query], {:type => 'artist'})
    @songs_by_referrer = Song.admin_search(params[:query], {:type => 'referrer'})
    @songs = @songs_by_title + @songs_by_artist + @songs_by_referrer
    @songs.uniq!
    render :partial => 'search_results'
  end

  collection_action :delete_comment, :method => :post do
    Comment.find(params[:id]).destroy()
    render :json => true
  end

  member_action :update_song_title, :method => :put do
    status = Song.find(params[:id]).update_attribute(:title, params[:new_title])
    render :json => {
      "id"=>params[:id],
      "success"=>status
    }
  end

  member_action :update_artist_name, :method => :put do
    artist = Artist.create(:name => params[:artist_name])
    status = Song.find(params[:id]).update_attribute(:artist_id, artist.id)
    render :json => {
      "id"=>params[:id],
      "success"=>status
    }
  end

  member_action :update_album_title, :method => :put do
    status = Song.find(params[:id]).album.update_attribute(:title, params[:new_album_title])
    render :json => {
      "id"=>params[:id],
      "success"=>status
    }
  end

  member_action :upload_album_art, :method => :post do
    song = Song.find(params[:id])
    song.album.art = params[:art]
    status = song.album.save!
    redirect_to '/admin'
  end

  member_action :nuke, :method => :post do
    song = Song.find(params[:id])
    status = song.destroy ? true : false
    render :json => {
      "id"=>params[:id],
      "success"=>status
    }
  end

end