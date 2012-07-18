class Song < ActiveRecord::Base
  has_and_belongs_to_many :genres
  has_and_belongs_to_many :playlists
  belongs_to :artist
  belongs_to :album
  has_many :favorites, :dependent=>:destroy
  has_many :heard_its, :dependent=>:destroy
  has_many :ratings, :dependent=>:destroy
  has_many :comments, :dependent=>:destroy, :order => "id ASC"
  has_and_belongs_to_many :playlists
  has_many :comment_likes, :dependent => :destroy
  has_many :comment_on_activities, :dependent => :destroy
  #belongs_to :uploader, :class_name => "User"

  #validates_presence_of :title
  validates_uniqueness_of :md5
  validates_uniqueness_of :media_source_url

  before_destroy :remove_from_playlists

  def sort_timestamp
    self.created_at
  end

  scope :admin_search, lambda {|query, options|
    type = options[:type]
    if type == 'artist'
      joins("join artists on songs.artist_id = artists.id").
      where("UCASE(artists.name) LIKE UCASE(?)", "%#{query}%")
    elsif type == 'title'
      where("UCASE(title) LIKE UCASE(?)", "%#{query}%")
    elsif type == 'referrer'
      joins("join users on songs.uploader_id = users.id").
      where("UCASE(users.username) LIKE UCASE(?)", "%#{query}%")
    end
  }

  # add paperclip with S3 stuff here
  has_attached_file :audio,
    :storage => :s3,
    :bucket => 'ishlist',
    :s3_credentials => {
      :access_key_id => 'AKIAJYS73LE6MCNYTC5A',
      :secret_access_key => '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'
    }

  #cache_records :store => :shared, :key => "song", :index => [:album_id, :artist_id]

  def uploader_photo
    User.find(self.uploader_id).fb_profile_pic ? User.find(self.uploader_id).fb_profile_pic.gsub('square','small') : User.find(self.uploader_id).photo.url rescue "/photos/original/missing.png"
  end

  def uploader
    User.find(self.uploader_id).username_gate rescue "The IshList"
  end

  def referrer
    self.uploader
  end

  def convert_seconds_to_time
    total_minutes = length_in_seconds / 1.minutes
    seconds_in_last_minute = length_in_seconds - total_minutes.minutes.seconds
    "#{total_minutes}m #{seconds_in_last_minute}s"
  end

  def avg_rating
    sprintf("%.1f",self.ratings.sum(:rating).to_f / self.ratings.count.to_f).to_f rescue 0

  end

  # fuck nil
  def download_count_number
    self.download_count.nil? ? 0 : self.download_count
  end

  def avg_listens
    all = self.heard_its.count
    heard = self.heard_its.where('heard_it = true').count
    (avg = heard.to_f/all.to_f).nan? ? 0 : avg rescue 0
  end

  def avg_listens_percent_string
    "#{(self.avg_listens*100).to_i}%"
  end

  def ish_rating
    rating = avg_rating*10 - avg_listens*100
    rating.ceil rescue 0
  end

  def media_source_name
    if media_source_url.match(/youtube/)
      'youtube'
    elsif media_source_url.match(/soundcloud/)
      'soundcloud'
    else
      false
    end
  end

  def remove_from_playlists
    self.playlists.each do |pl|
      pls = PlaylistsSongs.where(['playlists_songs.playlist_id = ? and playlists_songs.song_id in (?)', pl.id, [self.id]])
      pls.delete_all
      pl.songs.reset_positions
    end
  end

end
