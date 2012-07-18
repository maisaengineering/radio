class Artist < ActiveRecord::Base
  has_and_belongs_to_many :genres
  has_many :songs

  #validates_uniqueness_of :name

  #cache_records :store => :shared, :key => "arts"
end
