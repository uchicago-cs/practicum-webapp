class PagesController < ApplicationController

  before_action :redirect_if_not_logged_in, only: :request_advisor_access
  before_action :authenticate_user!, only: [:submissions,
                                            :request_advisor_access]
  before_action :is_admin?, only: [:submissions, :submission_drafts]
  before_action :get_submitted_submissions,
                only: [:submissions, :publish_all_statuses,
                       :approve_all_statuses, :change_all_statuses]
  before_action :get_unsubmitted_submissions, only: :submission_drafts
  before_action :redirect_if_invalid_quarter, only: :submission_drafts
  before_action :get_active_decided_submissions,
                only: [:publish_all_statuses, :approve_all_statuses,
                       :change_all_statuses]

  def home
  end

  def submissions
  end

  def submission_drafts
  end

  def change_all_statuses
    past_tenses = { "publish" => "published", "approve" => "approved" }

    @active_decided_submissions.each do |sub|
      sub.status_approved  = true if params['change'] == "approve"
      sub.status_published = true if params['change'] == "publish"
      if sub.valid?
        sub.save
      else
        flash.now[:error] = "Unable to #{params['change']} all statuses."
        render 'submissions' and return
      end
    end

    flash[:success] =
      "Successfully #{past_tenses[params['change']]} all statuses."
    redirect_to submissions_path
  end

  # Not DRY.
  def request_advisor_access
    if current_user.advisor_status_pending
      flash[:error] = "You have already requested advisor privileges. " \
      "Your request is pending administrator approval."
      redirect_to root_url
    elsif current_user.advisor
      flash[:error] = "You are already an advisor."
      redirect_to root_url
    end
  end

  def send_request_for_advisor_access
    if current_user.advisor_status_pending
      flash[:error] = "You have already requested advisor privileges. " +
      "Your request is pending administrator approval."
      redirect_to root_url
    elsif current_user.advisor
      flash[:error] = "You are already an advisor."
      redirect_to root_url
    else
      if advisor_request_params[:affiliation].empty? or
          advisor_request_params[:department].empty?
        flash.now[:error] = "You must provide your affiliation and department."
        render 'request_advisor_access' and return
      end
      current_user.
        update_attributes(advisor_status_pending: true,
                          affiliation: advisor_request_params[:affiliation],
                          department: advisor_request_params[:department])
      send_advisor_request_mail
      flash[:success] = "You have requested advisor privileges. You will be " +
      "notified if your privileges are elevated."
      redirect_to root_url
    end
  end

  # TODO: Use a more descriptive name?
  def update_all_submissions
    Submission.update_selected(params)

    flash[:success] =  "Updated selected applications."
    redirect_to submissions_path
  end

  private

  def advisor_request_params
    params.permit(:affiliation, :department)
  end

  def get_submitted_submissions
    if params[:year] and params[:season]
      @quarter = Quarter.where(year: params[:year],
                               season: params[:season]).take
      @active_submitted_submissions =
        Submission.submitted_submissions_in_quarter(@quarter)
    else
      @active_submitted_submissions =
        Submission.active_submitted_submissions
    end
  end

  def get_unsubmitted_submissions
    quarter = Quarter.where(year: params[:year], season: params[:season]).take
    @unsubmitted_submissions =
      Submission.unsubmitted_submissions(quarter)
  end

  def get_active_decided_submissions
    @active_decided_submissions = @active_submitted_submissions.
      where.not(status: "pending")
  end

  def send_advisor_request_mail
    User.admins.each do |admin|
      Notifier.request_for_advisor_access(current_user, admin).deliver
    end
  end

  def redirect_if_not_logged_in
    unless current_user
      flash[:error] = "Permission denied."
      redirect_to root_url
    end
  end

end
