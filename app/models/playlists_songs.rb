class PlaylistsSongs < ActiveRecord::Base
  default_scope :order => 'position'
	belongs_to :playlists
	belongs_to :songs
  validates_uniqueness_of :song_id, :playlist_id
  #cache_records :store => :shared, :key => "plssong", :index => [:song_id, :playlist_id]
end
