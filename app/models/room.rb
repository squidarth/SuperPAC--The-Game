class Room
  include Mongoid::Document

  field :name, :type => String
  field :turn, :type => Integer
  has_many :users

  def game_state
    {:users => self.users}


  end



end
