class PagesController < ApplicationController

  # skip_before_action :authenticate_user!, except: :submissions
  before_action :authenticate_user!, only: [:submissions,
                                            :request_advisor_access]
  before_action :is_admin?, only: :submissions
  before_action :get_current_submissions, only: [:submissions,
                                                 :publish_all_statuses,
                                                 :approve_all_statuses]
  before_action :get_current_decided_submissions, only: [:publish_all_statuses,
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
    @current_decided_submissions.each do |sub|
      sub.status_published = true
      if sub.valid?
        sub.save
      else
        flash.now[:error] = "Unable to publish all statuses."
        render 'submissions' and return
      end
    end
    flash[:success] = "Successfully published all statuses."
    redirect_to submissions_path
  end

  def approve_all_statuses
    # Not DRY.
    @current_decided_submissions.each do |sub|
      sub.status_approved = true
      if sub.valid?
        sub.save
      else
        flash.now[:error] = "Unable to approve all statuses."
        render 'submissions' and return
      end
    end
    flash[:success] = "Successfully approved all statuses."
    redirect_to submissions_path
  end

  def request_advisor_access
  end

  def send_request_for_advisor_access
    User.admins.each do |admin|
      Notifier.request_for_advisor_access(current_user, admin).deliver
    end

    redirect_to root_url, flash:
      { success: "You have requested advisor privileges." }
  end

  private

  def get_current_submissions
    @current_submissions = Submission.current_submissions
  end

  def get_current_decided_submissions
    @current_decided_submissions = @current_submissions.
      where.not(status: "pending")
  end

end
