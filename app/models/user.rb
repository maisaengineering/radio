#my darkness broods and looms across the already pitch black
#while u trust me for my gentle soul: a deep shadow follows everywhere the demon goes.
#the evil has far more sinister undertones.
#the burning image of hell is a permanent landmark of my mind.
#is it all in good taste or is that just blood that i'm tasting

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable,
         :rememberable,
         :trackable,
         :validatable,
         :omniauthable,
         :registerable,
         :timeoutable,
         :authentication_keys => [:username]

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :remember_me
  # protect admin
  attr_protected :admin

  has_many :playlists, :dependent => :destroy
  has_many :songs, :class_name => "Song", :foreign_key => "uploader_id", :dependent => :destroy
  has_many :favorites, :dependent => :destroy # meant to call it favoriting...
  has_many :authentications, :dependent => :destroy
  has_many :recent_activities, :dependent => :destroy
  has_many :comment_likes, :dependent => :destroy
  has_many :comment_on_activities, :dependent => :destroy
  has_many :ratings, :dependent => :destroy
  has_many :hookup_entries, :dependent => :destroy
  #validates_uniqueness_of :handle
  #validates_uniqueness_of :username

  has_attached_file :photo,
    :storage => :s3,
    :bucket => 'ishlist',
    :s3_credentials => {
      :access_key_id => 'AKIAJYS73LE6MCNYTC5A',
      :secret_access_key => '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'
    }

  def admin?
    self.admin == true
  end

  def username_gate
    self.admin ? "The IshList" : self.username
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    image = access_token.info.image
    if user = User.where(:email => data.email).first
      user.username = data.first_name + data.last_name.split('').first
      user.fb_profile_pic = image
    else
      user = User.new(:email => data.email, :username => data.first_name + data.last_name.split('').first, :fb_profile_pic => image,:password => Devise.friendly_token[0,20])
    end

    # if ya can't beat em, grease 'em!
    user.authentications.destroy_all

    user.authentications.build(:provider => access_token["provider"], :uid => access_token["uid"], :token => access_token['credentials']['token'], :user_id => user.id)
    user.save

  end

  def facebook
    @fb_user ||= Koala::Facebook::API.new(self.authentications.find_by_provider('facebook').token)
  end


  def self.new_with_session(params, session)
    super.tap do |user|
     data = session["devise.facebook_data"]
     
     if !data.nil?
       user.email = data["email"]
       self.handle = data["nickname"]
     else
      user = User.new(params[:user])
      user.save
     end
    end
  end


  def self.find_for_database_authentication(warden_conditions)
     conditions = warden_conditions.dup
     username = conditions.delete(:username)
     where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => username.strip.downcase }]).first
  end

end
