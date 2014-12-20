module StatusMethods

  def accepted?
    status == "accepted"
  end

  def rejected?
    status == "rejected"
  end

  def pending?
    status == "pending"
  end

  def draft?
    status == "draft"
  end

  def in_current_quarter?
    Quarter.active_quarters.include? self.quarter
  end

end
