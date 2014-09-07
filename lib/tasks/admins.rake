namespace :db do
  desc "Put initial admins into the database"

  domain = "uchicago.edu"

  task make_admins: :environment do
    @borja = User.new(cnet: "borja", email: "borja@" + domain,
                      first_name: "Borja", last_name: "Sotomayor",
                      student: false, admin: true)
    @slance = User.new(cnet: "slance", email: "slance@" + domain,
                       first_name: "Stefan", last_name: "Lance",
                       student: false, admin: true)
    @borja.save(validate: false)
    @slance.save(validate: false)
  end
end
