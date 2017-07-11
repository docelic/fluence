class HomeController < ApplicationController
  # get /
  def index
    redirect_to "/pages/home"
  end
end
