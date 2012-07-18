Ish::Application.routes.draw do

  devise_for :users, ActiveAdmin::Devise.config.merge({:controllers =>  {:sessions => "sessions", :registrations => "registrations", :omniauth_callbacks => "users/omniauth_callbacks"}}) do
    match '/login' => "devise/sessions#new", :as => :login
    match '/auth/:provider/callback' => 'devise/sessions#create'
    match '/logout' => "devise/sessions#destroy", :as => :logout
    match '/users/sign_in.json' => 'sessions#create'
    match '/users/register.json' => 'registrations#create'
    match '/register' => "registrations#new", :as => :new_user_registration
  end

  ActiveAdmin.routes(self)

  match '/song_uploader' => 'main#song_uploader'

  match '/next_song' => "main#next_song"
  match '/previous_song' => "main#previous_song"
  match '/next_song_paneled' => "main#next_song_paneled"
  match '/previous_song_paneled' => "main#previous_song_paneled"
  match '/main/get_station_image_url' => "main#get_station_image_url"

  match '/get_album_art/:id' => "main#get_album_art"
  match '/share_audio' => "main#share_audio"
  match '/favorite_track' => "main#favorite_track"
  match '/fan_track' => "main#fan_track"
  match '/rate_it' => "main#rate_it"
  match '/fetch_rating' => "main#fetch_rating"
  match '/heard_it' => "main#heard_it"
  match '/fetch_heard_it' => "main#fetch_heard_it"
  match '/havent_heard' => "main#havent_heard"
  match '/download_track' => "main#download_track"
  match '/like_activity' => "main#like_activity"
  match '/not_logged_in' => "main#not_logged_in"
  match '/radio/:playlist/:song_name' => "main#track"
  match '/post_comment_on_activity' => "main#post_comment_on_activity"
  match '/chart_comments' => "main#chart_comments"
  match '/upload_songs' => "main#upload_songs"
  match '/recent_activities' => "main#recent_activities"
  match '/tag_songs' => "main#tag_songs"
  match '/my_profile' => "main#profile_page"
  match '/comments_on_activity/:class/:id' => "main#comments_on_activity"
  match '/radio' => "main#radio"
  match '/more_recent_activities/:song_id/:count' => "main#more_recent_activities"
  match '/prev_recent_activities/:song_id/:count' => "main#prev_recent_activities"
  match '/parse' => "main#parse"
  match '/dilly_yo' => "main#dilly_yo"
  match '/hook_ups' => "main#hook_ups"
  match '/search_browse' => "main#search_browse"
  match '/search_results' => "main#search_results"
  match '/todays_hookup_entries' => "main#todays_hookup_entries"
  match '/upload_art/:song_id' => "main#upload_art"
  match '/todays_hookup_entries' => "main#todays_hookup_entries"
  match '/main/post_comment' => "main#post_comment"
  match '/get_comments/:song_id' => "main#get_comments"
  match "/create_hook_up_entry/:user_id" => "main#create_hook_up_entry"
  match '/post_track' => "main#post_track"

  match '/next_and_previous' => "main#next_and_previous"

  match '/feedback' => "main#feedback"
  match '/comments' => "main#comments"

  match '/facebook_a_track' => "main#facebook_a_track"
  match '/tweeter_a_track' => "main#tweeter_a_track"


  root :to => "main#index"

end
