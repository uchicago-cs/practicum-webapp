class Evaluation < ActiveRecord::Base

  default_scope { order('evaluations.created_at DESC') }

  belongs_to :submission, -> { where status: "accepted" },
             foreign_key: "submission_id"
  belongs_to :evaluation_template

  serialize :survey

  validates :advisor_id, presence: true
  validates :student_id, presence: true
  validates :project_id, presence: true
  validates_uniqueness_of :student_id, scope: :project_id

  validate :submission_status_is_sufficient, on: :create
  validate :mandatory_questions_answered

  delegate :email, to: :student, prefix: :student, allow_nil: true
  delegate :email, to: :advisor, prefix: :advisor, allow_nil: true
  delegate :name, to: :project, prefix: :project, allow_nil: true
  delegate :accepted?, to: :submission, prefix: true, allow_nil: true
  delegate :status_approved?, to: :submission, prefix: true, allow_nil: true
  delegate :status_published?, to: :submission, prefix: true, allow_nil: true

  after_create :send_evaluation_submitted

  def student
    User.find(student_id)
  end

  def advisor
    User.find(advisor_id)
  end

  def project
    Project.find(project_id)
  end

  def set_survey(survey_params)
    self.survey = survey_params
    s = self.evaluation_template.survey
    self.survey.each do |q, r|
      t = s.find { |k, h| h["question_prompt"] == q }[1]["question_type"]
      survey[q] = ((survey[q] == "1") ? "Yes" : "No") if t == "Check box"
    end
  end

  def set_attributes_on_create(survey_params)
    self.assign_attributes(student_id: submission.student_id,
                           project_id: submission.project_id,
                           advisor_id: submission.project_advisor_id)
    self.set_survey(survey_params[:survey])
  end

  private

  def send_evaluation_submitted
    User.admins.each { |ad| Notifier.evaluation_submitted(self, ad).deliver }
  end

  def submission_status_is_sufficient
    message = "Status must be approved, published, and accepted."
    errors.add(:base, message) unless self.submission_accepted? and
      self.submission_status_approved? and self.submission_status_published?
  end

  def mandatory_questions_answered
    # This would be easier if we stored all the survey information in the
    # evaluation object.
    unanswered = false

    s = self.evaluation_template.survey

    survey.each do |q, r|
      m = s.find { |k, h| h["question_prompt"] == q }[1]["question_mandatory"]
      # Store t/f values, not "1"/"0", in the EvaluationTemplate's survey col.
      if r.blank? and (m == "1" ? true : false)
        unanswered = true
        break
      end
    end

    message = "You must answer all mandatory questions."
    errors.add(:base, message) if unanswered
  end

end
