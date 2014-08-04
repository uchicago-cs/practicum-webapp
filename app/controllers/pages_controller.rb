class PagesController < ApplicationController

  # skip_before_action :authenticate_user!, except: :submissions
  before_action :authenticate_user!, only: [:submissions,
                                            :request_advisor_access]
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

  def request_advisor_access
  end

  def send_request_for_advisor_access
    User.admins.each do |admin|
      Notifier.request_for_advisor_access(current_user, admin).deliver
    end

    redirect_to root_url, notice: "You have requested advisor privileges."
  end

end
