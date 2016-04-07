class Author < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :articles
  has_many :comments
  has_attached_file :photo, :styles => { :circle => "40x40", :nano => "30x30",:small => "50x50>",:medium => "200x200>" }
 
validates_attachment_size :photo, :less_than => 5.megabytes
validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png']
  devise :database_authenticatable, :registerable, :omniauthable, 
         :recoverable, :rememberable, :trackable, :validatable, :omniauth_providers => [:facebook]

     def self.find_for_oauth(auth, signed_in_resource = nil)

    # Get the identity and user if they exist
    identity = Identity.find_for_oauth(auth)

    # If a signed_in_resource is provided it always overrides the existing user
    # to prevent the identity being locked with accidentally created accounts.
    # Note that this may leave zombie accounts (with no associated identity) which
    # can be cleaned up at a later date.
    author = signed_in_resource ? signed_in_resource : identity.author

    # Create the user if needed
    if author.nil?

      # Get the existing user by email if the provider gives us a verified email.
      # If no verified email was provided we assign a temporary email and ask the
      # user to verify it on the next step via UsersController.finish_signup
      email_is_verified = auth.info.email && (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      author = Author.where(:email => email).first if email

      # Create the user if it's a new registration
      if author.nil?
        author = Author.new(photo:process_uri(auth.info.image).sub('?sz=50', '?sz=256'),
          name: auth.extra.raw_info.name,
          
          #authorname: auth.info.nickname || auth.uid,
          email: email ? email : auth.extra.raw_info.email,
          password: Devise.friendly_token[0,20]
        )
       
        author.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.author != author
      identity.author = author
      identity.save!
    end
    author
  end

  def email_verified?
    self.email && self.email !~ TEMP_EMAIL_REGEX
  end
def self.process_uri(uri)
   avatar_url = URI.parse(uri)
   avatar_url.scheme = 'https'
   avatar_url.to_s
end
 
end


