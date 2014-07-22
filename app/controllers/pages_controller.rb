class PagesController < ApplicationController

  # skip_before_action :authenticate_user!, except: :submissions
  before_action :authenticate_user!, only: :submissions
  before_action :is_admin?, only: :submissions

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

  private

    def is_admin?
      redirect_to(root_url) unless current_user.admin?
    end

end
