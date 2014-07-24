class Quarter < ActiveRecord::Base

  has_many :projects

  validates :season, presence: true,
            inclusion: { in:  %w(winter spring summer autumn) }
  validates :year, presence: true, numericality: true, length: { is: 4 }
  validates :current, presence: true
  validates_uniqueness_of :season, scope: :year,
                          message: "That's already the current quarter."
  validate :only_one_current_quarter, on: :save

  def Quarter.current_quarter
    quarter = Quarter.where(current: true)
    [quarter.season, quarter.year]
  end

  def Quarter.set_current_false
    old = Quarter.where(current: true).take
    old.update_attributes(current: false) if old
  end

  def only_one_current_quarter
    # if ...
    #   errors.add(:current, "Only one quarter can be current")
    # end
  end
end
