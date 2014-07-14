class PagesController < ApplicationController

  #  before_action :signed_in_user, only: :submissions
  before_action :authenticate_user!, only: :submissions
  # Use Devise's authenticate_user! to ensure that the user is signed in
  # before viewing the submissions page

  def home
  end

  def about
  end

  def contact
  end

  def help
  end

  def submissions
  end

  # private

  # def signed_in_user
    
  # end
  
end
