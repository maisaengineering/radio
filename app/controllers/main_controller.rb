#ISHLIST BACKEND ENGINE CODE 1.0
#codename dankplayer
# "isnt more code better?"
class MainController < ApplicationController
  include MainHelper
  AUTOPLAY = true
  layout 'new_player_v2', :only => [:radio, :track]
  APP_ID = "363088097064753" #facebook
  GOOGLE_KEY = "AIzaSyD8V2h_RX2sdKpF39AKFIwNUcLPQV-ioFw"

  #before_filter :check_logged_in, :except => [:index, :radio, :get_comments, :next_song, :previous_song, :next_song_paneled, :previous_song_paneled, :not_logged_in]
  before_filter :check_logged_in, :only => [:post_comment, :upload_art, :post_track, :download_track, :favorite_track, :fan_track, :rate_it, :heard_it, :havent_heard, :upload_songs, :like_activity, :post_comment_on_activity]
  before_filter :get_all_stations, :only => [:radio, :track]
  before_filter :set_chat_token, :only => [:radio, :track] # in app controller

  #caches_page :radio, :index #, :track

  def facebook_a_track
    @graph = Koala::Facebook::GraphAPI.new(current_user.authentications[0].token)
    me = current_user.facebook

    playlist = params[:playlist]
    song_id = params[:song_id]
    song = Song.find(song_id)

    if ENV['RAILS_ENV'] == "development"
      @graph.put_wall_post("ishlist:listen_to", {:name => song.title, :link => "http://localhost:3000/playlist/#{playlist}/track/#{song_id}"})
    else
      @graph.put_wall_post("ishlist:listen_to", {:name => song.title, :link => "http://www.ishlist.com/playlist/#{playlist}/track/#{song_id}"})
    end
    render :json => { :message => "facebook_success" }.to_json
  end

  def tweeter_a_track
    playlist = params[:playlist]
    song_id = params[:song_id]
    song = Song.find(song_id)
    render :json => { :url => "http://www.twitter.com/share?text=#{('ishlist:listen_to  ' + song.title).gsub(' ', '+')}&url=http://www.ishlist.com/radio/#{playlist.gsub(" ","-")}/#{song.title.gsub(" ","_")}" }.to_json
  end

  def like_activity
    if params[:class] == "Song"
      if CommentLike.find(:all,:conditions => ['user_id =? AND song_id =?',current_user.id,params[:id]]).blank?
        like_act = CommentLike.new()
        like_act.user_id = current_user.id
        like_act.song_id = params[:id]
        like_act.save
      end
      render :json => {:count => Song.find(params[:id]).comment_likes.count}
    elsif params[:class] == "Comment"
      if CommentLike.find(:all,:conditions => ['user_id =? AND comment_id =?',current_user.id,params[:id]]).blank?
        like_act = CommentLike.new()
        like_act.user_id = current_user.id
        like_act.comment_id = params[:id]
        like_act.save
      end
      render :json => {:count => Comment.find(params[:id]).comment_likes.count}
    elsif params[:class] == "Favorite"
      if CommentLike.find(:all,:conditions => ['user_id =? AND favorite_id =?',current_user.id,params[:id]]).blank?
        like_act = CommentLike.new()
        like_act.user_id = current_user.id
        like_act.favorite_id = params[:id]
        like_act.save
      end
      render :json => {:count => Favorite.find(params[:id]).comment_likes.count}
    end
  end

  def recent_activities
    @song = Song.find(params[:song_id])
    recent_comments = @song.comments
    recent_likes = @song.favorites
    @recently_active_objects = [@song] + recent_comments + recent_likes
    @recently_active_objects = @recently_active_objects.sort { |x,y| y.sort_timestamp <=> x.sort_timestamp }
    @more_flag = true if 8 >= @recently_active_objects.count
    @recently_active_objects = @recently_active_objects[0 .. 7]
  end
  
  def more_recent_activities
    @song = Song.find(params[:song_id])
    recent_comments = @song.comments
    recent_likes = @song.favorites
    @recently_active_objects = [@song] + recent_comments + recent_likes
    @recently_active_objects = @recently_active_objects.sort { |x,y| y.sort_timestamp <=> x.sort_timestamp }
    from_count = params[:count].to_i * 8
    to_count = from_count + 7
    @next_flag = true if to_count >= @recently_active_objects.count-1
    @recently_active_objects = @recently_active_objects[from_count .. to_count]
  end


  def prev_recent_activities
    @song = Song.find(params[:song_id])
    recent_comments = @song.comments
    recent_likes = @song.favorites
    @recently_active_objects = [@song] + recent_comments + recent_likes
    @recently_active_objects = @recently_active_objects.sort { |x,y| y.sort_timestamp <=> x.sort_timestamp }
    to_count = (((params[:count].to_i) - 1) * 8) -1
    from_count = to_count - 7
    @prev_flag = true if from_count == 0
    @recently_active_objects = @recently_active_objects[from_count .. to_count]
  end


  def next_and_previous
    if params[:playlist] == "Latest Shares"
      first = Song.last
      last = Song.first
      next_art = first.album.art.url rescue "/arts/original/missing.png"
      last_art = last.album.art.url rescue "/arts/original/missing.png"
      song_hash = {:next_art => next_art,
                   :previous_art => last_art,
                   :next_title => first.title,
                   :previous_title => last.title,
                   :next_id => first.id,
                   :previous_id => last.id}
    elsif params[:playlist] == "My Favorites"
      first = current_user.favorites.ordered.last.song
      last = current_user.favorites.ordered.first.song
      fav = current_user.favorites.ordered
      future_art = fav[fav.count-2].song.album.art.url
      past_art = fav[1].song.album.art.url
      next_art = first.album.art.url rescue "/arts/original/missing.png"
      last_art = last.album.art.url rescue "/arts/original/missing.png"
      song_hash = {:next_art => next_art,
                   :previous_art => last_art,
                   :next_title => first.title,
                   :previous_title => last.title,
                   :next_id => first.id,
                   :previous_id => last.id,
                   :future_art => future_art,
                   :past_art => past_art}
    else
      playlist = Playlist.find_by_name(params[:playlist].gsub("-"," "))
      first = playlist.songs.first
      last = playlist.songs.last
      next_art = first.album.art.url rescue "/arts/original/missing.png"
      last_art = last.album.art.url rescue "/arts/original/missing.png"
      song_hash = {:next_art => next_art,
                   :previous_art => last_art,
                   :next_title => first.title,
                   :previous_title => last.title,
                   :next_id => first.id,
                   :previous_id => last.id}
    end
    render :json => song_hash.to_json
  end

  def get_station_image_url
    playlist = Playlist.find_by_name(params[:name]).station_image_url
    render :json => { :url => playlist.to_s }.to_json
  end

  def get_comments
    comments = Song.find(params[:song_id]).comments
    render :json => {:html => render_to_string(:partial => "comment", :collection => comments), :anti_caching_time => Time.now.to_s}.to_json
  end

  def post_comment
    song = Song.find(params[:song_id])
    comment = Comment.new(params[:comment])
    comment.user_id = current_user.id
    comment.save
    song.comments << comment
    song.save
    RecentActivity.create(:activity_type=> "Comment",:user_id => current_user.id,:activity => params[:comment][:comment],:song_id => params[:song_id])
    render :json => {:message => 'comment_success'}.to_json
  end
  
  def comments_on_activity
    if params[:class] == "Song"
      @activity = Song.find(params[:id])
      @comments = @activity.comment_on_activities
    elsif params[:class] == "Comment"
      @activity = Comment.find(params[:id])
      @comments = @activity.comment_on_activities
    elsif params[:class] == "Favorite"
      @activity = Favorite.find(params[:id])
      @comments = @activity.comment_on_activities
    end
  end

  def post_comment_on_activity
    if params[:activity_class] == "Song"
      comment_act = CommentOnActivity.new()
      comment_act.user_id = current_user.id
      comment_act.song_id = params[:activity_id]
      comment_act.activity_comment = params[:activity_comment]
      comment_act.save
      render :json => {:count => Song.find(params[:activity_id]).comment_on_activities.count}
    elsif params[:activity_class] == "Comment"
      comment_act = CommentOnActivity.new()
      comment_act.user_id = current_user.id
      comment_act.comment_id = params[:activity_id]
      comment_act.activity_comment = params[:activity_comment]
      comment_act.save
      render :json => {:count => Comment.find(params[:activity_id]).comment_on_activities.count}
    elsif params[:activity_class] == "Favorite"
      comment_act = CommentOnActivity.new()
      comment_act.user_id = current_user.id
      comment_act.favorite_id = params[:activity_id]
      comment_act.activity_comment = params[:activity_comment]
      comment_act.save
      render :json => {:count => Favorite.find(params[:activity_id]).comment_on_activities.count}
    end
  end

  def upload_art
    @song_id = params[:song_id]
    song = Song.find(@song_id)
    song.album = Album.find_or_create_by_title(song.title)

    art_file = !params[:art_file].nil? ? params[:art_file] : UrlTempfile.new(params[:art_url])
    # add art
    song.album.art = art_file
    song.album.save
    # add comment
    unless params[:ref_comment] == ""
      comment = Comment.new
      comment.user_id = current_user.id
      comment.comment = params[:ref_comment]
      comment.save
      song.comments << comment
    end
    song.save
    if HookupEntry.find(:all,:conditions => ['user_id =? AND entry_type =? AND created_at >=?',current_user.id,"Shared a song",Date.today.beginning_of_day()]).blank?
      HookupEntry.create(:user_id => current_user.id, :entry_type => "Shared a song")
    end
    RecentActivity.create(:activity_type=> "Share",:user_id => current_user.id,:song_id => song.id)
    render :json => {:message => 'art_success',:latest_song => song.title.gsub(" ","_").gsub(".","~")}.to_json
  end


  def tag_songs
    @song_id = params[:song_id]
    song = Song.find(@song_id)
    @images = Google::Search::Image.new(:query => song.title + " " + song.artist.name , :api_key => GOOGLE_KEY)
  end

  def parse
    channel = params[:channel]
    method = params[:method]
    message = params[:message]
    chat_token = params[:chat_token]

    # ident
    user = User.find_by_chat_token(chat_token)

    if method == "join"
      user.update_attribute("current_playlist", channel)
    elsif method == "chat"
      chat_tokens = User.where(["current_playlist = ?", channel]).map(&:chat_token)
      chat_tokens.each do |t| Juggernaut.publish(t, "CHAT!!|!!#{user.email}: #{message}") end
    elsif method == "pm"
      token = User.find_by_email(channel).chat_token
      Juggernaut.publish(token, "PM!!|!!#{user.email}: #{message}")
      Juggernaut.publish(chat_token, "PM!!|!!#{user.email}: #{message}")
    elsif method == "lr" # request (accept/deny/request)
      token = User.find_by_email(channel).chat_token
      Juggernaut.publish(token, "LR!!|!!#{user.email}: #{message}")
    elsif method == "lraccept" # accept, message is player pos
      token = User.find_by_email(channel).chat_token
      Juggernaut.publish(token, "LRACCEPT!!|!!#{user.email}: #{message}")
    elsif method == "lrdeny" # request (accept/deny/request)
      token = User.find_by_email(channel).chat_token
      Juggernaut.publish(token, "LRDENY!!|!!#{user.email}: #{message}")
    end

    render :nothing => true
  end

  def index
    redirect_to :action => :radio
  end

  def radio
    first_station = @stations.find_by_name("Top 25")
    session[:current_playlist] = first_station.name
    session[:playlist_listened] = [first_station.songs.last.id]
    @song_hash = make_song_hash(:next, session[:current_playlist], nil)
    song = Song.find(first_station.songs.first.id)
    song.play_count += 1
    song.save
  end

  def track
    playlist = Playlist.find_by_name(params[:playlist].gsub("-"," "))
    params[:song_name].slice!(0) if params[:song_name].slice(0) == '_'
    all_songs = Song.find_all_by_title(params[:song_name].gsub("_"," ").gsub("~","."))
    if playlist.name == "Latest Shares"
      @song = all_songs[0]
    else
      all_songs.each do|s|
        @song = s if !playlist.songs.map{|x| x.id}.index(s.id).nil?
      end
    end
    session[:current_playlist] = playlist.name
    session[:playlist_listened] = [playlist.songs.last.id] if !playlist.songs.blank?
    @song_hash = make_song_hash(:next, session[:current_playlist], @song.id)
    s = Song.find(@song.id)
    s.play_count += 1
    s.save
    render :action => :radio
  end

  def download_track
    song = Song.find(params[:song_id])
    link = song.download_link
    link = song.media_source_url.match(/soundcloud/) && link != nil ? "#{link}?client_id=#{SC_CLIENT_ID}" : link
    song.update_attribute(:download_count, song.download_count_number+1) if link
    render :json => {:link => link}
  end

  def next_song_paneled
    last_listened = params[:current_song_id]
    song_hash = make_song_hash(:next, params[:playlist])
      # skip
    if params[:playlist] == "My Favorites"
      id = Favorite.find(:first,:conditions => ['user_id =? AND song_id =?',current_user.id,params[:next_song_id]]).id
      fav_list = current_user.favorites.ordered.collect { |fav| fav.id }
      index = fav_list.index(id)
      if index == 0
        index1 = fav_list.length+1
      else
        index1 = index
      end
      song_hash[:next_id] = Favorite.find(fav_list[index1-2]).song.id
      song_hash[:next_title] = Favorite.find(fav_list[index1-2]).song.title
      song_hash[:next_art] = Favorite.find(fav_list[index1-2]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:future_art] = Favorite.find(fav_list[index1-3]).song.album.art.url rescue "/arts/original/missing.png"
      if index == 0
        index2 = fav_list.length
      else
        index2 = index
      end
      song_hash[:previous_id] = Favorite.find(fav_list[index2-1]).song.id
      song_hash[:previous_title] = Favorite.find(fav_list[index2-1]).song.title
      song_hash[:previous_art] = Favorite.find(fav_list[index2-1]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:past_art] = Favorite.find(id).song.album.art.url rescue "/arts/original/missing.png"
    else
      if song_hash[:next_id].to_i == last_listened.to_i || song_hash[:previous_id].to_i == last_listened.to_i
        song_hash = make_song_hash(:next, params[:playlist])
      end
    end
    render :json => song_hash.to_json
  end

  def previous_song_paneled
    last_listened = params[:current_song_id]
    song_hash = make_song_hash(:prev, params[:playlist], params[:current_song_id])
    # skip
    if params[:playlist] == "My Favorites"
      id = Favorite.find(:first,:conditions => ['user_id =? AND song_id =?',current_user.id,params[:previous_song_id]]).id
      fav_list = current_user.favorites.ordered.collect { |fav| fav.id }
      index = fav_list.index(id)
      if fav_list.length == index+1
        index1 = -1
      elsif fav_list.length == index+2
        index1 = -2
      else
        index1 = index
      end
      song_hash[:previous_id] = Favorite.find(fav_list[index1+2]).song.id
      song_hash[:previous_title] = Favorite.find(fav_list[index1+2]).song.title
      song_hash[:previous_art] = Favorite.find(fav_list[index1+2]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:future_art] = Favorite.find(id).song.album.art.url rescue "/arts/original/missing.png"
      if fav_list.length == index+1
        index2 = -1
      else
        index2 = index
      end
      song_hash[:next_id] = Favorite.find(fav_list[index2+1]).song.id
      song_hash[:next_title] = Favorite.find(fav_list[index2+1]).song.title
      song_hash[:next_art] = Favorite.find(fav_list[index2+1]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:past_art] = Favorite.find(fav_list[index2+3]).song.album.art.url rescue "/arts/original/missing.png"
    else
      if song_hash[:next_id].to_i == last_listened.to_i || song_hash[:previous_id].to_i == last_listened.to_i
        song_hash = make_song_hash(:prev, params[:playlist])
      end
    end
    render :json => song_hash.to_json
  end

  def next_song
    song_hash = make_song_hash(:next, params[:playlist], params[:current_song_id])
    if params[:playlist] == "My Favorites"
      id = Favorite.find(:first,:conditions => ['user_id =? AND song_id =?',current_user.id,song_hash[:id]]).id
      fav_list = current_user.favorites.ordered.collect { |fav| fav.id }
      index = fav_list.index(id)
      if index == 0
        index1 = fav_list.length
      else
        index1 = index
      end
      song_hash[:next_id] = Favorite.find(fav_list[index1-1]).song.id
      song_hash[:next_title] = Favorite.find(fav_list[index1-1]).song.title
      song_hash[:next_art] = Favorite.find(fav_list[index1-1]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:future_art] = Favorite.find(fav_list[index1-2]).song.album.art.url rescue "/arts/original/missing.png"
      if fav_list.length == index+1
        index2 = -1
      else
        index2 = index
      end
      song_hash[:previous_id] = Favorite.find(fav_list[index2+1]).song.id
      song_hash[:previous_title] = Favorite.find(fav_list[index2+1]).song.title
      song_hash[:previous_art] = Favorite.find(fav_list[index2+1]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:past_art] = Favorite.find(fav_list[index2+2]).song.album.art.url rescue "/arts/original/missing.png"
    end
    if current_user
      is_fav = !Favorite.find(:first , :conditions => ['user_id = ? AND song_id = ?', current_user.id.to_i,song_hash[:id].to_i]).blank?
    else
      is_fav = false
    end
    song_hash[:is_fav] = is_fav
    s = Song.find(params[:current_song_id])
    s.play_count += 1
    s.save
    render :json => song_hash.to_json
  end

  def previous_song
    song_hash = make_song_hash(:next, params[:playlist], params[:current_song_id])
    if params[:playlist] == "My Favorites"
      id = Favorite.find(:first,:conditions => ['user_id =? AND song_id =?',current_user.id,song_hash[:id]]).id
      fav_list = current_user.favorites.ordered.collect { |fav| fav.id }
      index = fav_list.index(id)
      if index == 0
        index1 = fav_list.length
      else
        index1 = index
      end
      song_hash[:next_id] = Favorite.find(fav_list[index1-1]).song.id
      song_hash[:next_title] = Favorite.find(fav_list[index1-1]).song.title
      song_hash[:next_art] = Favorite.find(fav_list[index1-1]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:future_art] = Favorite.find(fav_list[index1-2]).song.album.art.url rescue "/arts/original/missing.png"
      if fav_list.length == index+1
        index2 = -1
      else
        index2 = index
      end
      song_hash[:previous_id] = Favorite.find(fav_list[index2+1]).song.id
      song_hash[:previous_title] = Favorite.find(fav_list[index2+1]).song.title
      song_hash[:previous_art] = Favorite.find(fav_list[index2+1]).song.album.art.url rescue "/arts/original/missing.png"
      song_hash[:past_art] = Favorite.find(fav_list[index2+2]).song.album.art.url rescue "/arts/original/missing.png"
    end
    if current_user
      is_fav = !Favorite.find(:first , :conditions => ['user_id = ? AND song_id = ?', current_user.id.to_i,song_hash[:id].to_i]).blank?
    else
      is_fav = false
    end
    s = Song.find(params[:current_song_id])
    s.play_count += 1
    s.save
    song_hash[:is_fav] = is_fav
    render :json => song_hash.to_json
  end

  def favorite_track
    is_fav = false
    if Favorite.find(:first , :conditions => ['user_id =? AND song_id =?', current_user.id.to_i,params[:song_id].to_i])
      Favorite.find(:first , :conditions => ['user_id =? AND song_id =?', current_user.id.to_i,params[:song_id].to_i]).destroy()
      RecentActivity.create(:activity_type=> "Favorite",:user_id => current_user.id,:activity => "unfavorite",:song_id => params[:song_id])
      message = 'unfavorite_success'
      render :json => {:message => message}.to_json
    else
      is_fav = true
    begin
      favorite = Favorite.new
      favorite.song_id = params[:song_id].to_i
      favorite.user_id = current_user.id.to_i
      favorite.save!
      message = 'favorite_success'
    rescue
      message = 'favorite_success'
    ensure
      RecentActivity.create(:activity_type=> "Favorite",:user_id => current_user.id,:activity => "favorite",:song_id => params[:song_id])
      render :json => {:message => message,:is_fav => is_fav}.to_json
    end
    end
  end

  def fan_track
    begin
      fan = Fan.new
      fan.artist_id = Song.find(params[:song_id]).artist.id
      fan.user_id = current_user.id.to_i
      fan.save!
      message = 'fan_success'
    rescue
      message = 'fan_fail'
    ensure
      render :json => {:message => message}.to_json
    end
  end

  def rate_it
    song = Song.find(params[:song_id])
    Rating.create(:rating => params[:rating], :song_id => song.id, :user_id => current_user.id)
    today_rated = Rating.find(:all,:conditions => ['user_id =? AND created_at >=?',current_user.id,Date.today.beginning_of_day()]).count
    unless today_rated == 10
      hash = {:message => "rate_success", :rating => song.ish_rating, :avg_rating => song.avg_rating}
    else
      HookupEntry.create(:user_id => current_user.id, :entry_type => "Rating")
      hash = {:message => "rate_success_with_congrats", :rating => song.ish_rating, :avg_rating => song.avg_rating}
    end
    render :json => hash.to_json
  end

  def fetch_rating
    rated = false
    song = Song.find(params[:song_id])
    if current_user && !song.ratings.select {|s| s.user_id == current_user.id}.blank?
      rated = true 
    end
    json = {:already_rated => rated, :rating => song.ish_rating, :avg_rating => song.avg_rating}
    render :json => json
  end

  def heard_it
    song = Song.find(params[:song_id])
    begin
      song.heard_its << HeardIt.create(:song_id => song.id, :user_id => current_user.id, :heard_it => true)
      song.save!
      message = "heard_success"
    rescue
      message = "heard_success"
    ensure
      render :json => {:message => message, :rating => song.ish_rating, :avg_listens => song.avg_listens_percent_string}.to_json
    end
  end

  def fetch_heard_it
    rated = false
    song = Song.find(params[:song_id])
    if current_user && !song.heard_its.select {|s| s.user_id == current_user.id}.blank?
     rated = true 
    end
    message = "heard_success"
    render :json => {:already_rated => rated, :message => message, :avg_listens => song.avg_listens_percent_string}.to_json
  end

  def havent_heard
    song = Song.find(params[:song_id])
    begin
      song.heard_its << HeardIt.create(:song_id => song.id, :user_id => current_user.id, :heard_it => false)
      song.save!
      message = "heard_success"
    rescue
      message = "heard_success"
    ensure
      render :json => {:message => message, :rating => song.ish_rating, :avg_listens => song.avg_listens_percent_string}.to_json
    end
  end

  def not_logged_in
    render :json => {:message => "login"}.to_json
  end

  def todays_hookup_entries
    @hooks = HookupEntry.all
  end

  def create_hook_up_entry
    if HookupEntry.find(:all,:conditions => ['user_id =? AND entry_type =? AND created_at >=?',params[:user_id],"fb Share",Date.today.beginning_of_day()]).blank?
      HookupEntry.create(:user_id => params[:user_id], :entry_type => "fb share")
      render :json => {:new_entry => "true"}
    else
      render :json => {:new_entry => "false"}
    end
  end

  def post_track
    begin
      link = params[:link]
      if link != ""
          if link.match(/youtube/)

            client = YouTubeIt::Client.new(:dev_key => YOUTUBE_API_KEY)
            token = CGI::parse(link.split("?")[1])["v"][0].strip

            video = client.video_by(token)
            if video.state.nil? || video.state[:name] == "published"
              @song = Song.create!(:title => params[:title]) do |song|
                song.artist = Artist.find_or_create_by_name(params[:artist])
                song.uploader_id = current_user.id
                song.download_link = link
                song.media_source_url = link
              end
            else
              render :json => {:message => "song_fail"}
              return
            end
          elsif link.match(/youtu.be/)
            client = YouTubeIt::Client.new(:dev_key => YOUTUBE_API_KEY)
            token = link.split(".be/")[1]
            video = client.video_by(token)
            if video.state.nil? || video.state[:name] == "published"
              @song = Song.create!(:title => params[:title]) do |song|
                song.artist = Artist.find_or_create_by_name(params[:artist])
                song.uploader_id = current_user.id
                song.download_link = video.player_url
                song.media_source_url = video.player_url
              end
            else
              render :json => {:message => "song_fail"}
              return
            end
          elsif link.match(/soundcloud/)
            resolve = HTTParty.get(URI.encode("http://api.soundcloud.com/resolve.json?url=#{link}&client_id=#{SC_CLIENT_ID}"))

            if resolve.parsed_response == {"errors"=> [{"error_message"=>"404 - Not Found"}]} || resolve == nil
              render :json => {:message => "song_fail"}
              return
            end

            parsed_link = link.split("/")

            @song = Song.create!(:title => params[:title]) do |song|
              song.artist = Artist.find_or_create_by_name(params[:artist])
              song.uploader_id = current_user.id
              song.download_link = resolve["download_url"]
              song.media_source_url = link
              song.save
            end

          end
        else
          audio = params[:song][:audio]
          mp3_info = Mp3Info.new(audio.path)
          song = Song.new

          artist = Artist.find_or_create_by_name(params[:artist])
          song.artist = artist
          song.title = params[:title]
          song.can_download = true if params[:can_download] == "yes"
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
          song.update_attribute(:media_source_url, song.audio.url)
          @song = song

      end

      render :json => {:message => "song_success", :song_id => @song.id}
    rescue
      render :json => {:message => "song_fail"}
    end

  end

  private

  def get_all_stations
    unless user_signed_in?
    @stations = Playlist.god_like_and_not_special
    else
    @stations = Playlist.god_like
    end
  end

end
