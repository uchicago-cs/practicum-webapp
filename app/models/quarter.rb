class Quarter < ActiveRecord::Base

  has_many :projects

  validates :season, presence: true,
                     uniqueness: { scope:   :year,
                                   message: "That quarter already exists." },
                     inclusion:  { in:      %w(winter spring summer autumn) }
  validates :year, presence: true, numericality: true, length: { is: 4 }

  before_destroy :prevent_if_current
  after_validation :set_current_false
  before_validation :downcase_season

  def Quarter.current_quarter
    Quarter.where(current: true).take
    # Use `uniq`?
  end

  def Quarter.formatted_current_quarter
    quarter = Quarter.where(current: true).take
    if quarter
      [quarter.season.capitalize, quarter.year].join(" ")
    else
      "this quarter"
    end
  end

  def formatted_quarter
    [season.capitalize, year].join(" ")
  end

  private

  def set_current_false
    Quarter.where(current: true).update_all(current: false)
  end

  def prevent_if_current
    self.errors[:base] << "Cannot delete the current quarter." if self.current?
  end

  def downcase_season
    self.season.downcase!
  end

end
