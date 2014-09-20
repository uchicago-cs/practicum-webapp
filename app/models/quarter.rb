class Quarter < ActiveRecord::Base

  default_scope { order('quarters.created_at DESC') }
  scope :current_quarter, -> { where(current: true).take }

  has_many :projects

  validates :season, presence: true,
                     uniqueness: { scope:   :year,
                     message: "A quarter with that season and " +
                     "year already exists." },
                     inclusion:  { in:      %w(winter spring summer autumn),
                                   message: "Invalid quarter." }
  validates :year, presence: true, numericality: true, length: { is: 4 }

  validate :deadlines_between_start_and_end_dates

  before_destroy    :prevent_if_current
  after_validation  :set_current_false
  before_validation :downcase_season

  def Quarter.deadlines
    [:start_date, :project_proposal_deadline, :student_submission_deadline,
     :advisor_decision_deadline, :admin_publish_deadline, :end_date]
  end

  def deadline(deadline)
    # Can we just do "#{deadline}_deadline".to_sym instead?
    self.send("#{deadline}_deadline".to_sym)
  end

  private

  def set_current_false
    to_set_false = (Quarter.where.not(id: self.id)).where(current: true)
    if self.current?
      to_set_false.each do |q|
        q.current = false
      end
    end
  end

  def prevent_if_current
    message = "You cannot delete the current quarter."
    errors.add(:base, message) if self.current?
  end

  def downcase_season
    self.season.downcase!
  end

  # We might change this later (e.g., allow deadlines beyond the end_date). (?)
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
