class Rating < ActiveRecord::Base
	belongs_to :song
    belongs_to :user
	validates :user_id, :uniqueness=>{ :scope=> :song_id}

  #cache_records :store => :shared, :key => "rtng", :index => [:song_id, :user_id]
end
