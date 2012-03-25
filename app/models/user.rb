class User
  include Mongoid::Document
  include Mongoid::Paperclip
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :null => false, :default => ""
  field :encrypted_password, :type => String, :null => false, :default => ""

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  field :poll_number, :type => Integer, :default => 50
  field :previous_move, :type => String, :default => " "
  field :current_event, :type => String, :default => " "
  field :marketing_budget, :type => Integer, :default => 1000
  field :staff_budget, :type => Integer, :default => 1000
  field :travel_budget, :type => Integer, :default => 1000
 
  field :ready, :type => Boolean
  
  has_mongoid_attached_file :avatar,
    :storage => :s3,
    :bucket => 'superpac',
    :styles => {:thumb => "75x75>", :small => "150x150>", :normal => "250x250>", :large => "450x450>" }, 
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => ":attachment/:id/:style.:extension" 



  ## Encryptable
  # field :password_salt, :type => String

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String
  belongs_to :room

  def as_json(options={})
      {:name => self.name, :poll_number => self.poll_number, :image => self.avatar.url, :latest_news => self.current_event}

  end

      def get_next_moves
        return ["Get money from oil executive" ,"Take picture with minority children", "Meet with famous foreign leader", "Have affair with secretary","Photo-op in old manufacturing town"].sample(3)
      end


      def get_next_event
          possible_events = ["You: I can see Alaska from my backyard!", "You: I strongly believe that one day man and fish will coexist (what?)"]  
          
          hash = {"Get money from oil executive" =>  ["The media found out you took money from oil executive!", "Your budget has increased!"], "Take picture with minority children" => ["You gaffed up!", "Everyone loves you!"], "Meet with famous foreign leader" => ["You're good on foreign affairs!", "You're not president yet!"],  "Have affair with secretary" => ["You get caught", "Nobody found out but you're still an idiot..."],"Photo-op in old manufacturing town" => ["You support the manufacturing industry", "You're not fooling anyone--you're still just a rich kid"]}
            if(hash[self.previous_move])
                possible_events << hash[self.previous_move].sample(1)
            end
            possible_events.flatten!
            self.current_event = possible_events.sample(1)
            self.save!
            return self.current_event 



      end
      
end
