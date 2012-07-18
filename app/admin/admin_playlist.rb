ActiveAdmin.register Playlist do

  member_action :sort_playlist do
    @playlist = Playlist.find(params[:id])
    @playlist.songs.reset_positions
  end

  member_action :move_song_position do
    playlist = Playlist.find(params[:id])
    song = Song.find(params[:song_id])
    position = params[:position].to_i
    playlist.songs.move_to_position(song, position)
    render :partial => "playlist_song_order", :locals => {:playlist => playlist}
  end

  collection_action :index do
  	redirect_to :action => :playlist_tool
  end

  collection_action :new do
    redirect_to :action => :playlist_tool
  end

  collection_action :move_song_up, :method => :post do
  	playlist = Playlist.find(params[:playlist_id])
  	song = Song.find(params[:id])
  	playlist.songs.move_higher(song)
  	redirect_to :action => :index
  end

	collection_action :move_song_down, :method => :post do
		playlist = Playlist.find(params[:playlist_id])
		song = Song.find(params[:id])
		playlist.songs.move_lower(song)
		redirect_to :action => :index
	end

	collection_action :playlist_tool do
		@all_songs = Song.order('created_at DESC')
		@unplaylisted_songs = Song.order('created_at DESC').reject {|s| s.playlists.count > 0}
		@god_like_playlists = Playlist.god_like_and_not_special
		@special_playlists = Playlist.god_like_and_special
	end


	collection_action :create_playlist, :method => :post do
		playlist = Playlist.new(params[:playlist])
		playlist.god_like = 1
		playlist.save
		flash[:notice] = "Your playlist was created"
		redirect_to :action => :playlist_tool
	end

  member_action :change_playlist_image, :method => :post do
    playlist = Playlist.find(params[:id])
    playlist.station_name_image = params[:playlist][:station_name_image]
    playlist.save
    flash[:notice] = "Image Changed"
    redirect_to :action => :playlist_tool
  end

	collection_action :add_to_playlist, :method => :post do
		songs = Song.where(['id in (?)', params[:song_ids]])
		playlist = Playlist.find(params[:playlist])
		playlist.songs << songs
    playlist.songs.move_to_bottom(songs)
		status = playlist.save
    if params[:dashboard]
		  render :json => {
        "id"=>playlist.id,
        'song_id'=>songs.first.id,
        'name'=>playlist.name,
        "success"=>status
      }
    else
		  redirect_to :action => :playlist_tool
    end
	end

	collection_action :remove_songs, :method => :post do
		pl = params[:playlist]
		playlist_id = pl.keys[0]
		song_arr = pl[playlist_id]["songs"]
		pls = PlaylistsSongs.where(['playlists_songs.playlist_id = ? and playlists_songs.song_id in (?)', playlist_id, song_arr])
		pls.delete_all
		Playlist.find(playlist_id).songs.reset_positions
    if params[:dashboard]
  		  render :json => {
          "id"=>playlist_id,
          'song_id'=>song_arr[0],
          "success"=>!pls.any?
        }
    else
  		  redirect_to :action => :playlist_tool
    end
	end


	member_action :delete_playlist, :method => :delete do
		playlist = Playlist.find(params[:id])
		playlist.destroy
	end



end