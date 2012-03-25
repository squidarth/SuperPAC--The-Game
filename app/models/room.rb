class Room
  include Mongoid::Document

  field :name, :type => String
  field :turn, :type => Integer, :default => 0
  has_many :users

  def game_state
    {:users => self.users}
  end

  def update_pollnums
    @users = self.users
    update1 = rand(-5...5)
    update2 = rand(-5...5)
    self.turn = self.turn + 1
    self.save
    @users[0].poll_number = @users[0].poll_number + update1
    @users[1].poll_number = @users[1].poll_number - update1
    #@users[1].poll_number = @user[1].poll_number + update2
    #@users[2].poll_number = @user[2].poll_number - update2

    @users.each do |user|
        user.save!
    end

  end


end
