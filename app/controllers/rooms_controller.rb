class RoomsController < ApplicationController

    respond_to :json, :html
    
    def index
        @rooms = Room.all
    end

    def show
        @room = Room.find(params[:id])
    end

    def create
        @room = Room.create(params[:room])
        @room.save!
        redirect_to rooms_path
    end

    def add_user
        @room = Room.find(params[:id])
        if @room.users.count < 2
            @room.users << current_user
            @room.save
            if @room.users.count == 2
                Juggernaut.publish("channel1", "start")
            end

            redirect_to room_path(@room) 
        else
            redirect_to rooms_path

        end

   end

    def leave_room
        current_user.room_id = nil
        current_user.save!
        redirect_to rooms_path
    end


    def ready
       @room = Room.find(params[:id])
       current_user.update_attributes!(params[:user])
       current_user.ready = true
       current_user.save
       ready = true
       @room.users.each do |user|
         unless user.ready
            ready = false
         end
       end 

       if ready
           @room.update_pollnums
           Juggernaut.publish("channel1", "ready")
       end
       render :json => {:result => "Success"}
    end

    def get_state
        @room = Room.find(params[:id])
        @user = current_user
        @user.ready = false
        @user.save!
        render :json => {:users => @room.users, :next_moves => @user.get_next_moves, :event => @user.get_next_event, :stage => @room.turn}
    end




end
