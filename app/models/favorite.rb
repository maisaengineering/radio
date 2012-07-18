class Favorite < ActiveRecord::Base
	belongs_to :song
	belongs_to :user
	has_many :comment_likes, :dependent => :destroy
	has_many :comment_on_activities, :dependent => :destroy
	validates :user_id, :uniqueness=>{ :scope=> :song_id}
	#cache_records :store => :shared, :key => "fav", :index => [:song_id, :user_id]
	scope :ordered , :order => "id ASC"
	def sort_timestamp
      self.created_at
    end
end
