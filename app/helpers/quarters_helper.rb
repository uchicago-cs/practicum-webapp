module QuartersHelper

  def new_quarter_btn_class(change)
    btn_type = (change == "create" ? "success" : "primary")
    "btn btn-#{btn_type}"
  end

  # TODO: Remove
  def current_change_warning
    "Changing the current quarter will prevent students from applying to "+
    "previous quarters, although you may change which quarter is the current "+
    "one at any time."
  end

  def formatted_quarter(quarter)
    [quarter.season.capitalize, quarter.year].join(" ")
  end

  def fmt_quarter_show_current(quarter)
    formatted_quarter(quarter) + (quarter.active? ? " (active)" : "")
  end

  def default_season
    # Choose the next quarter instead of this one?
    seasons = ["winter", "spring", "summer", "autumn"]
    seasons[((Time.now.month - 1) / 3)].capitalize
  end

  def start_date
    season_dates = { "spring" => "4th Monday in March",
                     "summer" => "4th Monday in June",
                     "autumn" => "4th Monday in September",
                     "winter" => "1st Monday in January" }

    # Note: Chronic gets the hour (17) correct, but when this Time object is
    # used in #default_deadline, the hour is reset to 12. To correct this,
    # we add 5.hours in #default_deadline.
    Chronic.parse(season_dates[default_season.downcase],
                  now: Time.local(Time.now.year, 1, 1, 17, 0, 0)).to_datetime
  end

  def end_date
    start_date + 10.weeks + 5.days
  end

  def default_deadline(deadline_type)
    # 5 PM on Friday of 3rd, 6th, and 8th weeks.
    deadline_weeks = { "proposal" => 2, "submission" => 5, "decision" => 7,
                       "admin" => 8 }
    start_date + deadline_weeks[deadline_type].weeks + 4.days + 5.hours
  end

end
