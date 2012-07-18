class Genre < ActiveRecord::Base
  has_and_belongs_to_many :songs
  has_and_belongs_to_many :artists

  #validates_uniqueness_of :name
end
