# vegeta, what did the scouter say about his power level?

module MainHelper

  MAGIC_PLAYLISTS = ['My Favorites', 'Latest Shares']

	def some_long_algorithm(num1, num2)
		num1**num2
	end

  def strip_null(str)
    new_str = ""
    str.each_byte do |byte|
      new_str << byte.chr unless byte == 00
    end
    new_str
  end

  def parse_id3_apic(apic)
    enc=apic.unpack('c')[0]
    case enc
    when 0, 3
           arr = apic.unpack('c Z* c Z* a*')
           pixstr=arr[4]
           mime_type = arr[1]
           art = pixstr
    when 1, 2
           arr = apic.unpack('c Z* c a*')
           cp=arr[3]
           mime_type = arr[1]
           comment, pixstr=cp.split(/\000\000/,2)
           comment+=pixstr.slice!(0, 1) while pixstr[0]==?\000
           art = pixstr
    else
           Rails.logger.info("Encoding of #{song.path} APIC frame was not found.")
    end
    [art, mime_type]
  end

  def get_song(dir, playlist_name, song_id, playlist_listened)

    playlist = Playlist.find_by_name(playlist_name)

    if dir == :next
      if song_id == nil
        if !MAGIC_PLAYLISTS.include?(playlist_name)
          current_song = playlist.next_song(playlist_listened.last, 1)
        elsif playlist_name == "My Favorites"
          favorite_songs = current_user.favorites.collect { |fav| fav.song_id }
          top_songs = Song.where(['id in (?)', favorite_songs])
          current_song = top_songs.order("RAND()").first
        elsif playlist_name == "Latest Shares"
          current_song = playlist.latest_next_song(playlist_listened.last, 1)
        end
      else
        current_song = Song.find(song_id)
      end
    elsif dir == :future
        if !MAGIC_PLAYLISTS.include?(playlist_name)
          current_song = playlist.next_song(playlist_listened.last, 2)
        elsif playlist_name == "My Favorites"
          favorite_songs = current_user.favorites.collect { |fav| fav.song_id }
          top_songs = Song.where(['id in (?)', favorite_songs])
          current_song = top_songs.order("RAND()").first
        elsif playlist_name == "Latest Shares"
          current_song = playlist.latest_next_song(playlist_listened.last, 2)
        end
    elsif dir == :prev
        if !MAGIC_PLAYLISTS.include?(playlist_name)
          current_song = playlist.previous_song(playlist_listened.last, 1)
        elsif playlist_name == "My Favorites"
          favorite_songs = current_user.favorites.collect { |fav| fav.song_id }
          top_songs = Song.where(['id in (?)', favorite_songs])
          current_song = top_songs.order("RAND()").first
        elsif playlist_name == "Latest Shares"
          current_song = playlist.latest_previous_song(playlist_listened.last, 1)
        end
    elsif dir == :past
        if !MAGIC_PLAYLISTS.include?(playlist_name)
          current_song = playlist.previous_song(playlist_listened.last, 2)
        elsif playlist_name == "My Favorites"
          favorite_songs = current_user.favorites.collect { |fav| fav.song_id }
          top_songs = Song.where(['id in (?)', favorite_songs])
          current_song = top_songs.order("RAND()").first
        elsif playlist_name == "Latest Shares"
          current_song = playlist.latest_previous_song(playlist_listened.last, 2)
        end
    end
    current_song
  end

  def format_comment_time(time)
    time = (time + Time.zone_offset(Time.now.zone)).strftime("%I:%M %p")
  end

  def format_hookup_entry_time(time)
    time = (time + Time.zone_offset(Time.now.zone)).strftime("%I:%M %p")
  end

  def make_song_hash(dir, playlist, song_id = nil)
    if session[:current_playlist] != playlist
      if !MAGIC_PLAYLISTS.include?(playlist)
        session[:playlist_listened] = [Playlist.find_by_name(playlist).songs.last.id]
      elsif playlist == "Latest Shares"
        session[:playlist_listened] = [Song.order('created_at DESC').select('distinct songs.*').limit(100).map(&:id).last]
      end
      session[:current_playlist] = playlist
    end

    @current_song = get_song(dir, playlist, song_id, session[:playlist_listened])

    session[:playlist_listened] << @current_song.id

    @previous_song = get_song(:prev, playlist, nil, session[:playlist_listened])
    @next_song = get_song(:next, playlist, nil, session[:playlist_listened])
    @future_song = get_song(:future, playlist, nil, session[:playlist_listened])
    @past_song = get_song(:past, playlist, nil, session[:playlist_listened])



    previous_art = @previous_song.album.art.url rescue "/arts/original/missing.png"
    album_art =  @current_song.album.art.url rescue "/arts/original/missing.png"
    next_art = @next_song.album.art.url rescue "/arts/original/missing.png"
    future_art = @future_song.album.art.url rescue "/arts/original/missing.png"
    past_art = @past_song.album.art.url rescue "/arts/original/missing.png"

    song_hash = {:id => @current_song.id,
      :next_id => @next_song.id,
      :previous_id => @previous_song.id,
      :artist => @current_song.artist.name,
      :title => @current_song.title,
      :next_title => @next_song.title,
      :previous_title => @previous_song.title,
      :favorites => @current_song.favorites.count,
      :ish_rating => @current_song.ish_rating,
      :download => @current_song.download_link,
      :logged_in => user_signed_in?,
      :anti_caching_time => Time.now.to_s,
      :art => album_art,
      :next_art => next_art,
      :future_art => future_art,
      :past_art => past_art,
      :previous_art => previous_art,
      :media_source_url => @current_song.media_source_url,
      :playlist => playlist,
      :shared_by => @current_song.uploader,
      :user_picture => @current_song.uploader_photo}

    if @current_song.audio_file_name
      song_hash.merge!({:type => 'mp3'})
    elsif @current_song.media_source_name == "soundcloud"
      song_hash.merge!({:type => @current_song.media_source_name})
    elsif @current_song.media_source_name == "youtube"
      song_hash.merge!({:type => @current_song.media_source_name})
      song_hash[:media_source_url] += "&fmt=18"
    end

    song_hash
  end

end















