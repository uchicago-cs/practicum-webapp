class Quarter < ActiveRecord::Base

  attr_reader :current

  default_scope { order('quarters.created_at DESC') }

  scope :active_quarter, -> {
    where("start_date <= ? AND ? <= end_date",
          DateTime.now, DateTime.now).take }

  scope :active_quarters, -> {
    where("start_date <= ? AND ? <= end_date",
          DateTime.now, DateTime.now) }

  scope :future_quarters, -> { where("? < start_date", DateTime.now) }

  scope :open_for_proposals, -> {
    Quarter.active_quarters.where("? <= project_proposal_deadline",
                                   DateTime.now) }

  scope :open_for_submissions, -> {
    Quarter.active_quarters.where("? <= student_submission_deadline",
                                   DateTime.now) }

  has_many :projects
  has_many :evaluation_templates

  validates :season, presence: true,
                     uniqueness: { scope:   :year,
                     message: "A quarter with that season and " +
                     "year already exists." },
                     inclusion:  { in:      %w(winter spring summer autumn),
                                   message: "Invalid quarter." }
  validates :year, presence: true, numericality: true, length: { is: 4 }

  validate :deadlines_between_start_and_end_dates

  # Change name to `prevent_destroy_if_current`?
  before_destroy    :prevent_if_current
  before_validation :downcase_season

  def Quarter.active_exists?
    active_quarters.present?
  end

  # Rename to `active?` ?
  def active?
    (start_date <= DateTime.now) and (DateTime.now <= end_date)
  end

  def Quarter.deadlines
    [:start_date, :project_proposal_deadline, :student_submission_deadline,
     :advisor_decision_deadline, :admin_publish_deadline, :end_date]
  end

  def deadline(deadline)
    # Can we just do "#{deadline}_deadline".to_sym instead?
    self.send("#{deadline}_deadline".to_sym)
  end

  private

  def prevent_if_current
    message = "You cannot delete the current quarter."
    errors.add(:base, message) if self.active?
  end

  def downcase_season
    self.season.downcase!
  end

  def deadlines_between_start_and_end_dates
    message = "Deadlines must be between the quarter's start and end dates."
    if project_proposal_deadline <= start_date or
      student_submission_deadline <= start_date or
      advisor_decision_deadline <= start_date or
      end_date < project_proposal_deadline or
      end_date < student_submission_deadline or
      end_date < advisor_decision_deadline
        errors.add(:base, message)
    end
  end

end
