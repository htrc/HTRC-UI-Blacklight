class User < ActiveRecord::Base
# Connects this user object to Blacklights Bookmarks and Folders. 
 include Blacklight::User
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :provider, :uid
  # attr_accessible :title, :body

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account. 

  def to_s
    email
  end

  def self.find_for_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
 logger.debug "DEBUG -> USER #{user}" 
    unless user
      user = User.create!(
                          :uid => auth.uid,
                          :email => auth.info.email,
                          :provider => auth.provider,
                          :password => Devise.friendly_token[0,20]
                   )
    end
    user
  end

end
