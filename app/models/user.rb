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

  field :total_budget, :type => Integer, :default => 10000000
  field :perceived_intelligence, :type => Integer, :default => 100
  field :intouch, :type => Integer, :default => 100

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
      {:name => self.name, :intouch => self.intouch, :intelligence => self.perceived_intelligence, :budget => self.total_budget, :poll_number => self.poll_number, :image => self.avatar.url, :latest_news => self.current_event}

  end

    def reset
        self.perceived_intelligence = 100
        self.total_budget = 10000000
        self.intouch = 100
        self.previous_move = " "
        self.current_event = " "
        self.poll_number = 50
    end

      def get_next_moves
        return ["Get money from oil executive" ,"Take picture with minority children", "Meet with famous foreign leader", "Have affair with secretary","Photo-op in old manufacturing town", "Appear on Oprah Winfrey", "Research Opponent's Dark and Revolutionary Past", "Lead Mass Prayer", "Go to Superbowl", "Win Debate"].sample(3)
      end
    
      def change_stats
        hash = {" " => {:intelligence => 0, :budget => 0, :intouch => 0}, "Get money from oil executive" => {:intelligence => 0, :budget => 500000, :intouch => -15} ,"Take picture with minority children" => {:intelligence => 20, :budget => -10000, :intouch => 15}, "Meet with famous foreign leader" => {:intelligence => 30, :budget => -10000, :intouch => 0}, "Have affair with secretary"  => {:intelligence => 0, :budget => -10000, :intouch => -15},"Photo-op in old manufacturing town" => {:intelligence => 0, :budget => -10000, :intouch => 20}, "Appear on Oprah Winfrey" => {:intelligence => 10, :budget => -10000, :intouch => 15}, "Research Opponent's Dark and Revolutionary Past" => {:intelligence => 0, :budget => 0, :intouch => 10}, "Lead Mass Prayer" => {:intelligence => 0, :budget => -10000, :intouch => 20}, "Go to Superbowl" => {:intelligence => 20, :budget => -10000, :intouch => 15}, "Win Debate" => {:intelligence => 20, :budget => -10000, :intouch => -15}}
        if self.previous_move
            self.perceived_intelligence = self.perceived_intelligence + hash[self.previous_move][:intelligence]
            self.total_budget = self.total_budget + hash[self.previous_move][:budget]
            self.intouch = self.intouch = hash[self.previous_move][:intouch]
            self.save
        end  
    end


      def get_next_event
          self.change_stats
          possible_events = ["I was under medication when I made the decision to burn the tapes", "I'm not a witch...I'm you", "I can see Alaska from my backyard!", "You: I strongly believe that one day man and fish will coexist", "I love California, I practically grew up in Phoenix", "As yesterday's positive report card shows, childrens do learn when standards are high and results are measured"]  
            self.current_event = possible_events.sample
            self.save!
            return self.current_event 

      end
      
end
