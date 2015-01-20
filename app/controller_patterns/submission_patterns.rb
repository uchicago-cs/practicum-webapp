module SubmissionPatterns

  def create_or_update_submission(render_type)
    if params[:commit] == "Submit my application"
      @submission.assign_attributes(status: "pending") if render_type == :edit
      if @submission.save
        flash[:success] = "Application submitted."
        redirect_to users_submissions_path(year: @year, season: @season)
      else
        render render_type
      end
    elsif params[:commit] == "Save as draft"
      @submission.assign_attributes(status: "draft") if render_type == :new
      if @submission.save(validate: false)
        flash[:success] = "Application saved as a draft. You may edit it " +
          "by navigating to your \"my applications\" page."
        redirect_to users_submissions_path(year: @year, season: @season)
      else
        render render_type
      end
    end
  end

end
