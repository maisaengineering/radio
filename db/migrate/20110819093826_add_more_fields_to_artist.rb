class AddMoreFieldsToArtist < ActiveRecord::Migration
  def change
    add_column :artists, :name, :string
    add_column :artists, :email, :string
    add_column :artists, :city, :string
    add_column :artists, :state, :string
    add_column :artists, :zip, :string
    add_column :artists, :bio, :text   
  end
end
# 
# 1) Username
# 2) Password
# 3) Email address
# 4) Zip code
# 5) Base Location (City, State, Zip)
# 6) Short Bio
# 7) Musical Influences
# 8) Pictures
# 9) Genre(s) (up to 4)
# 10) Songs Artist has shared/ Uploaded
# 11) Songs the Artist has Rated and the rating for each
# 12) Videos the Artist has shared/uploaded
# 13) Previous Concerts
# 14) Upcoming Concerts
# 15) Users and locations for users who have requested concerts from this artist
# 16)  Artists 'Favorites' and order thereof
# 17) The Artists they have Fanned
# 18) The users who have 'Fanned' them
# 19) Hookups they have available(if any), and what the win rate is(1 in 20 etc)
# 20) Past Hookups with number of Plays used on each/ how many given out.
# 21) Total listens on each of Artists uploaded Songs
# 22) Average Song Rating for Artist's Songs
# 23) Average Ish Rating for Artist's Songs
# 24) All Hollers(Status Updates)
# 25) Comments on user and artists songs, comments, pictures
# 26) 'Digs' on user and artist songs, comments, pictures.
# 27) Artist account settings(notification, privacy, etc)
# 28) Currently online
# 29) Playlists recieved/sent.
# 30) Notes/Rants
# 31) Artists 'IshList' and order thereof.
# 32) Currently Online?
# 33) Credit card information
# 34) History of all purchases on site.
# 35) History of clicks to links outside of site.
# 36) Artist Playlists and order thereof
# 37) 'Gigs Requested'. 
# 38) Venues rated and rating of each