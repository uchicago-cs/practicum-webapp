class Quarter < ActiveRecord::Base

  has_many :projects

  validates :season, presence: true,
            inclusion: { in:  %w(winter spring summer autumn) }
  validates :year, presence: true, numericality: true, length: { is: 4 }
  validates_uniqueness_of :season, scope: :year,
                          message: "That quarter already exists."
  validate :only_one_current_quarter, on: :save

  def Quarter.current_quarter
    Quarter.where(current: true).take
    # Use `uniq`?
    # Also, this returns a Quarter instance, not just an ID.
    # (Compare with project.rb, L20.)
  end

  def Quarter.formatted_current_quarter
    quarter = Quarter.where(current: true).take
    if quarter
      [quarter.season.capitalize, quarter.year].join(" ")
    else
      "this quarter"
    end
  end

  # Should this be public?
  def Quarter.set_current_false
    old = Quarter.where(current: true).take
    old.update_attributes(current: false) if old
  end

  def only_one_current_quarter
    if self.current? and Quarter.where(current: true).count > 0
      errors.add(:current, "can only be 'true' for one quarter")
    end
  end

  def formatted_quarter
    [season.capitalize, year].join(" ")
  end

end
