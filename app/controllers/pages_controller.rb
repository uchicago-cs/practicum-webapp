class PagesController < ApplicationController

  # skip_before_action :authenticate_user!, except: :submissions
  before_action :authenticate_user!, only: [:submissions,
                                            :request_advisor_access]
  before_action :is_admin?, only: :submissions
  before_action :get_current_submissions, only: [:submissions,
                                                 :publish_all_statuses,
                                                 :approve_all_statuses]

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

  def publish_all_statuses
    # Note: #update_all skips validations! Fix this!
    if @current_submissions.update_all(status_published: true)
      flash[:notice] = "Successfully published all statuses."
      redirect_to submissions_path
    else
      flash[:alert] = "Unable to publish all statuses."
      render 'submissions'
    end
  end

  def approve_all_statuses
    # Not DRY.
    # Note: #update_all skips validations! Fix this!
    if @current_submissions.update_all(status_approved: true)
      flash[:notice] = "Successfully approved all statuses."
      redirect_to submissions_path
    else
      flash[:alert] = "Unable to approve all statuses."
      render 'submissions'
    end
  end

  def request_advisor_access
  end

  def send_request_for_advisor_access
    User.admins.each do |admin|
      Notifier.request_for_advisor_access(current_user, admin).deliver
    end

    redirect_to root_url, notice: "You have requested advisor privileges."
  end

  private

  def get_current_submissions
    @current_submissions = Submission.current_submissions
  end

end
