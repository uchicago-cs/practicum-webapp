class Project < ActiveRecord::Base

  belongs_to :user
  has_many :submissions

  validates :name, presence: true, uniqueness: true
  validates :deadline, presence: true
  validates :description, presence: true,
                         length: { minimum: 100, maximum: 1500 }

  def advisor_email
    User.find(self.advisor_id).email
    # If searching just by an id, then use `find`, not `find_by`.
  end

  def status
    if self.approved?
      "approved"
    else
      "unapproved"
    end
  end

end
