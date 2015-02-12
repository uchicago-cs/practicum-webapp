class EvaluationTemplate < ActiveRecord::Base

  validates :name,       presence: true, uniqueness: { scope: :quarter_id,
                                                       case_sensitive: false }
  validates :quarter_id, presence: true
  validates :start_date, presence: true
  validates :end_date,   presence: true

  validate :no_empty_questions,        on: :update
  validate :no_empty_radio_btn_opts,   on: :update
  validate :no_repeated_questions,     on: :update
  validate :end_date_after_start_date

  after_validation :set_active_inactive

  serialize :survey

  belongs_to :quarter
  has_many :evaluations

  attr_accessor :has_grade

  def EvaluationTemplate.current_active_available?
    if EvaluationTemplate.current_active
      EvaluationTemplate.current_active.end_date > DateTime.now and
        DateTime.now > EvaluationTemplate.current_active.start_date
    else
      false
    end
  end

  def EvaluationTemplate.current_active
    EvaluationTemplate.where(active: true).
      where(quarter: Quarter.active_quarter).take
  end

  def has_grade_question?
    survey.values.each { |q| return true if q["question_prompt"] == "Grade" }
    false
  end

  def delete_questions(delete_params)
    delete = false
    delete_params.each do |question_num, should_be_removed|
      if (should_be_removed == "1" ? true : false)
        survey.reject! { |key| key == question_num.to_i }
        delete = true
        # We're not `break`ing here, because we want to delete each question
        # that was marked as delete.
      end
    end
    delete
  end

  def reorganize_questions_after_deletion
    ordered_nums = survey.keys.sort
    ordered_nums.each_with_index do |num, index|
      if num != (index + 1)
        # If num == (index + 1), we would remove the pre-existing pair with
        # #reject!.
        survey[index+1] = survey[num]
        survey.reject! { |key| key == num }
      end
    end
  end

  def change_order(ordering_params)
    survey_copy = survey.clone
    ordering_params.each do |old_position, new_position|
      if old_position != new_position
        survey[new_position.to_i] = survey_copy[old_position.to_i]
      end
    end
  end

  def change_mandatory(mandatory_params)
    mandatory_params.each do |number, required|
      survey[number.to_i]["question_mandatory"] = required
    end
  end

  def edit_question(question_params)
    num    = question_params[:question_num].to_i
    type   = question_params[:question_type]
    prompt = question_params[:question_prompt]

    survey[num]["question_type"]   = type
    survey[num]["question_prompt"] = prompt
    if type == "Radio button" or type == "Check box (multiple choices)"
      survey[num]["question_options"] = question_params[:multiple_btn_opts]
    end
  end

  def update_survey(survey_params)
    delete = self.delete_questions(survey_params[:delete])
    self.reorganize_questions_after_deletion
    unless delete
      self.change_mandatory(survey_params[:mandatory])
      self.change_order(survey_params[:ordering])
    end
  end

  # TODO: Improve the method below.
  # Be careful with this... We shouldn't have to whitelist the allowed
  # attributes here: we should just use the strong params filter in the
  # controller.
  def update_basic_info(info_params)
    p = info_params[:evaluation_template]
    self.update_attributes(name: p[:name], quarter_id: p[:quarter_id],
                           active: p[:active], start_date: p[:start_date],
                           end_date: p[:end_date])
  end

  def add_question(survey_params)
    num = self.survey ? self.survey.length + 1 : 1
    self.survey = {} unless self.survey

    self.survey[num] = {
      "question_type"      => survey_params[:question_type],
      "question_prompt"    => survey_params[:question_prompt],
      "question_mandatory" => survey_params[:question_mandatory]
    }

    if survey_params[:question_type] == "Radio button" or
        survey_params[:question_type] == "Check box (multiple choices)"
      self.survey[num]["question_options"] =
        survey_params[:multiple_btn_opts]
    end
  end

  private

  def no_empty_questions
    message = "Questions cannot be blank."
    errors.add(:base, message) if
      survey.values.any? { |question| question.values.any?(&:blank?) }
  end

  def no_empty_radio_btn_opts
    blank_opts = false
    survey.each do |q, r|
      survey.find_all { |k, h| h["question_type"] == "Radio button" or
        h["question_type"] == "Check box (multiple choices)"}.each do |o|
        o[1]["question_options"].each do |num, option|
          if option.blank?
            blank_opts = true
            break
          end
        end
      end
    end

    message = "Radio button options cannot be blank."
    errors.add(:base, message) if blank_opts
  end

  def no_repeated_questions
    message = "Each question must be unique."
    prompts = survey.values.collect { |q| q["question_prompt"] }
    errors.add(:base, message) if prompts.length != prompts.uniq.length
  end

  # Make all other templates in this quarter inactive if this one is becoming
  # active. Similar to Quarter#set_current_false.
  def set_active_inactive
    to_set_inactive = (EvaluationTemplate.where.not(id: self.id)).
      where(active: true).where(quarter_id: self.quarter_id)
    if self.active?
      to_set_inactive.each { |t| t.update_attributes(active: false) }
    end
  end

  def end_date_after_start_date
    msg = "The end date must be after the start date."
    errors.add(:base, msg) if self.start_date >= self.end_date
  end

end
