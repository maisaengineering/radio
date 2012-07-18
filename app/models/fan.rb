class Fan < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => [:artist_id]
  #cache_records :store => :shared, :key => "fan", :index => [:user_id, :artist_id]
end
