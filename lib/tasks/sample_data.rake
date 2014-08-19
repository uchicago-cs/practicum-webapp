require 'faker'

# Also need to mark objects as published in some of these methods.

namespace :db do
  desc "Fill database with sample data"

  task populate: :environment do
    tables = [:evaluations, :evaluation_answers, :evaluation_questions,
              :evaluation_questions_evaluations, :submissions, :projects,
              :quarters, :users]
    tables.each do |table|
      delete_table(table)
    end

    make_users
    make_quarters
    make_projects
    make_submissions
    make_evaluations
  end
end

def delete_table(table)
  table_class = table.to_s.singularize.capitalize.constantize
  table_string = table.to_s

  table_class.delete_all
  ActiveRecord::Base.connection.execute("select setval(pg_get_serial_sequence('#{table}', 'id'), 1, false);")
  # Or "truncate tablename restart identity;" to delete records and
  # reset ID sequence.
end

def make_users

  # Create admin users
  2.times do |n|
    # name = "Admin Number #{n+1}"
    email = "admin-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password, student: false,
                 password_confirmation: password, admin: true)
  end

  # Create advisor users
  10.times do |n|
    # name = "Advisor Number #{n+1}"
    email = "advisor-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password, student: false,
                 password_confirmation: password, advisor: true)
  end

  # Create student users
  200.times do |n|
    # name = "Student Number #{n+1}"
    email = "student-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password,
                 password_confirmation: password, student: true)
  end

end

def make_projects
  advisors = User.where(advisor: true)
  x = -1
  advisors.each do |advisor|
    x += 1
    20.times do |n|
      content = Faker::Lorem.sentence(30)
      status = ["pending", "accepted", "rejected"].sample
      p = advisor.projects.build(description: content,
                                 expected_deliverables: content,
                                 prerequisites: content,
                                 related_work: [content, ""].sample,
                                 advisor_id: advisor.id,
                                 name: "Some Project #{20*x + n + 1}",
                                 deadline: DateTime.current,
                                 status: status,
                                 quarter_id: Quarter.ids.sample)
      p.save(validate: false)
    end
  end
end

def make_submissions
  students = User.where(student: true)
  students.each do |student|
    content = Faker::Lorem.sentence(30)
    project_id = (student.id % 50)+1
    status = ["pending", "accepted", "rejected"].sample
    if Project.find(project_id).accepted?
      sub = student.submissions.new(information: content,
                                    qualifications: content,
                                    courses: content,
                                    student_id: student.id,
                                    project_id: project_id,
                                    status: status)
      sub.this_user = User.find(1)
      if [true, false].sample
        sub.update_attributes(resume_file_name: "res2.pdf",
                              resume_content_type: "application/pdf")
      end
      sub.save(validate: false)
    end
  end
end

def make_evaluations
end

def make_quarters
  # Not DRY (see quarters_helper.rb)
  season_dates = { "spring" => "4th Monday in March",
                   "summer" => "4th Monday in June",
                   "autumn" => "4th Monday in September",
                   "winter" => "1st Monday in January" }
  deadline_weeks = { "proposal" => 2, "submission" => 5, "decision" => 7,
                     "admin" => 8 }
  5.times do |n|
    year = 2012 + n
    season = ((year == 2014) ? "summer" :
              %w(winter spring summer autumn).sample)
    start_date = Chronic.parse(season_dates[season.downcase],
                 now: Time.local(year, 1, 1, 12, 0, 0)).to_datetime
    ppd = start_date + deadline_weeks["proposal"].weeks + 4.days + 5.hours
    ssd = start_date + deadline_weeks["submission"].weeks + 4.days + 5.hours
    add = start_date + deadline_weeks["decision"].weeks + 4.days + 5.hours
    apd = start_date + deadline_weeks["admin"].weeks + 4.days + 5.hours
    end_date = start_date + 9.weeks + 5.days

    Quarter.new(season: season, year: year,
                current: year == 2014 ? true : false,
                start_date: start_date,
                project_proposal_deadline: ppd,
                student_submission_deadline: ssd,
                advisor_decision_deadline: add,
                admin_publish_deadline: apd,
                end_date: end_date).save
  end
end
