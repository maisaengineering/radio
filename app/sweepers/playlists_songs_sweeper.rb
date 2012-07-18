class PlaylistsSongsSweeper < ActionController::Caching::Sweeper
  observe PlaylistsSongs # This sweeper is going to keep an eye on the Product model

  # If our sweeper detects that a Product was created call this
  def after_create(playlist_song)
    if playlist_song.playlist.god_like == true
      expires_page(:controller => :main, :page => :index)
      expires_page(:controller => :main, :page => :radio)
      #expires_page(:controller => :main, :page => :track)
    end
  end

  # If our sweeper detects that a Product was updated call this
  def after_update(playlist_song)
    if playlist_song.playlist.god_like == true
      expires_page(:controller => :main, :page => :index)
      expires_page(:controller => :main, :page => :radio)
      #expires_page(:controller => :main, :page => :track)
    end
  end

  # If our sweeper detects that a Product was deleted call this
  def after_destroy(playlist_song)
    if playlist_song.playlist.god_like == true
      expires_page(:controller => :main, :page => :index)
      expires_page(:controller => :main, :page => :radio)
      #expires_page(:controller => :main, :page => :track)
    end
  end

end