# it is pitch black
# you are likely
# to be eaten by a grue

class Playlist < ActiveRecord::Base
	has_and_belongs_to_many :songs, :order => 'playlists_songs.position', :list => true, :select => 'distinct songs.*'


	validates_uniqueness_of :name

  # block mass assignment only
  attr_protected :god_like, :special


	has_attached_file :station_name_image,
    :storage => :s3,
    :bucket => 'ishlist',
    :s3_credentials => {
      :access_key_id => 'AKIAJYS73LE6MCNYTC5A',
      :secret_access_key => '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'
    }

  def station_image_url
    url = "#{self.station_name_image.url()}"
  end

  #cache_records :store => :shared, :key => "plys"

  def previous_song(id, offset)
      id ||= self.songs.find(:all, :select => 'id').map(&:id).last
      songs = self.songs.find(:all, :select => 'id').map(&:id)
      index = songs.index(id) - offset
      index = index % songs.count
      prev_id = songs[index]
      Song.find(prev_id)
  end

  def next_song(id, offset)
      id ||= self.songs.find(:all, :select => 'id').map(&:id).first
      songs = self.songs.find(:all, :select => 'id').map(&:id)
      index = songs.index(id) + offset
      index = index % songs.count
      next_id = songs[index]
      Song.find(next_id)
  end

  # special magic

  # add not shared by admin when we have users
  def latest_previous_song(id, offset)
      id ||= Song.order('created_at DESC').select('distinct songs.*').limit(100).map(&:id).last
      songs = Song.order('created_at DESC').select('distinct songs.*').limit(100).map(&:id)
      index = songs.index(id) - offset
      index = index % songs.count
      prev_id = songs[index]
      Song.find(prev_id)
  end

  def latest_next_song(id, offset)
      id ||= Song.order('created_at DESC').select('distinct songs.*').limit(100).map(&:id).first
      songs = Song.order('created_at DESC').select('distinct songs.*').limit(100).map(&:id)
      index = songs.index(id) + offset
      index = index % songs.count
      next_id = songs[index]
      Song.find(next_id)
  end

  def self.god_like
  	where('god_like = true')
  end

  def self.god_like_and_not_special
    where('god_like = true and special = false')
  end

  def self.god_like_and_special
    where('god_like = true and special = true')
  end


end
