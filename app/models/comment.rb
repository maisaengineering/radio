class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :song
  has_many :comment_likes, :dependent => :destroy
  has_many :comment_on_activities, :dependent => :destroy
  #cache_records :store => :shared, :key => "comm", :index => [:song_id]
  def sort_timestamp
    self.created_at
  end
end
