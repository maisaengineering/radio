class Album < ActiveRecord::Base
	has_many :songs


  has_attached_file :art,
    :storage => :s3,
    :bucket => 'ishlist',
    :s3_credentials => {
      :access_key_id => 'AKIAJYS73LE6MCNYTC5A',
      :secret_access_key => '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'
    }

  validates_uniqueness_of :title

  #cache_records :store => :shared, :key => "alb"


end
