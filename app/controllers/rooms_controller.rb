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
        current_user.reset
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
        require "net/http"
        require 'json'
        uri = URI('http://api.nytimes.com/svc/search/v1/article?query=campaign&api-key=d9bfccca1229f4551db9b4316721eeed:3:57548361') 
        string = Net::HTTP.get(uri)
        result = JSON.parse(string)
        
        results = result["results"]
        
        titles = results.collect {|result| result["title"]}
        titles = titles.sample(5)
        @room = Room.find(params[:id])
        @user = current_user
        @user.ready = false
        @user.save!
        if @room.turn == 10
            other = @room.users.first 
            @room.users.each do |user|
                if user.name != current_user.name
                    other = user
                end
            end
            if other.poll_number > current_user.poll_number
                render :json => {:won => true}
            else
                render :json => {:lost => true}
            end
        elsif @room.turn == 3
            #trivia here
        render :json => {:trivia => true, :titles => titles, :me => current_user, :users => @room.users, :next_moves => @user.get_next_moves , :event => @user.get_next_event, :stage => @room.turn}

        else

        render :json => {:titles => titles, :me => current_user, :users => @room.users, :next_moves => @user.get_next_moves, :event => @user.get_next_event, :stage => @room.turn}
        end
    end




end
