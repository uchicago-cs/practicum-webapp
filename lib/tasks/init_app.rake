namespace :db do
  desc "Initialize the app:" +
    "\n- Put initial admins into the database" +
    "\n- Create a current quarter"

  task init_app: :environment do
    init_admins
    init_quarter
  end
end

def init_admins
  domain = "uchicago.edu"

  if User.where(cnet: "borja").exists?
    User.where(cnet: "borja").take.update_attributes(student: false,
                                                     admin: true)
  else
    @borja = User.new(cnet: "borja", email: "borja@cs." + domain,
                      first_name: "Borja", last_name: "Sotomayor",
                      student: false, admin: true)
    @borja.save(validate: false)
  end

  if User.where(cnet: "slance").exists?
    User.where(cnet: "slance").take.update_attributes(student: false,
                                                      admin: true)
  else
    @slance = User.new(cnet: "slance", email: "slance@" + domain,
                       first_name: "Stefan", last_name: "Lance",
                       student: false, admin: true)

    @slance.save(validate: false)
  end
end

def init_quarter
  if Quarter.where(current: true).exists?
    puts "A current quarter already exists."
  else
    Quarter.create(current: true, start_date: DateTime.now - 1.days,
                   project_proposal_deadline: DateTime.now,
                   student_submission_deadline: DateTime.now,
                   advisor_decision_deadline: DateTime.now,
                   admin_publish_deadline: DateTime.now,
                   end_date: DateTime.now + 3.months,
                   season: "Summer",
                   year: Date.current.year)
  end
end
