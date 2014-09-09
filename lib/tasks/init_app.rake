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
  if Quarter.current_quarter
    puts "A current quarter already exists."
  else
    @current_quarter = Quarter.new(current: true,
                                   start_date: DateTime.now - 1.days,
                                   end_date: DateTime.now + 3.months)
    @quarter.save
  end
end
