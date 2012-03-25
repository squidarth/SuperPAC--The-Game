class PagesController < ApplicationController
  def home
    if user_signed_in?
        redirect_to rooms_path

    end

  end

  def about
  end

  def contact
  end

end
