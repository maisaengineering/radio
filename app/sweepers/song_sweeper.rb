class SongSweeper < ActionController::Caching::Sweeper
  observe Song # This sweeper is going to keep an eye on the Product model

  # If our sweeper detects that a Product was created call this
  def after_create(song_song)
    if song_song.song.god_like == true
      expires_page(:controller => :main, :page => :index)
      expires_page(:controller => :main, :page => :radio)
      #expires_page(:controller => :main, :page => :track)
    end
  end

  # If our sweeper detects that a Product was updated call this
  def after_update(song_song)
    if song_song.song.god_like == true
      expires_page(:controller => :main, :page => :index)
      expires_page(:controller => :main, :page => :radio)
      #expires_page(:controller => :main, :page => :track)
    end
  end

  # If our sweeper detects that a Product was deleted call this
  def after_destroy(song_song)
    if song_song.song.god_like == true
      expires_page(:controller => :main, :page => :index)
      expires_page(:controller => :main, :page => :radio)
      #expires_page(:controller => :main, :page => :track)
    end
  end

end