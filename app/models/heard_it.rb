class HeardIt < ActiveRecord::Base
	belongs_to :song
	belongs_to :user

	validates :user_id, :uniqueness=>{ :scope=> :song_id}

	# scope :heard, where('heard_it = true')
	# scope :havent, where('havent_heard = true')

  #cache_records :store => :shared, :key => "hrdit", :index => [:song_id, :user_id]
end
