class RoomsController < ApplicationController

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
        @room.users << current_user
        @room.save
        redirect_to room_path(@room) 
    end




end
