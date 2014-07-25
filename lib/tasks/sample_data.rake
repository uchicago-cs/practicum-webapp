require 'faker'

namespace :db do
  desc "Fill database with sample data"

  task populate: :environment do
    tables = [:evaluations, :submissions, :projects, :quarters, :users]
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
  ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = '#{table_string}'")
end

def make_users

  # Create admin users
  2.times do |n|
    # name = "Admin Number #{n+1}"
    email = "admin-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password,
                 password_confirmation: password, admin: true)
  end

  # Create advisor users
  10.times do |n|
    # name = "Advisor Number #{n+1}"
    email = "advisor-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password,
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
  advisors = User.where(advisor: true).all
  x = -1
  advisors.each do |advisor|
    x += 1
    20.times do |n|
      content = Faker::Lorem.sentence(30)
      status = ["pending", "accepted", "rejected"].sample
      advisor.projects.create!(description: content,
                               expected_deliverables: content,
                               prerequisites: content,
                               related_work: [content, ""].sample,
                               advisor_id: advisor.id,
                               name: "Some Project #{20*x + n + 1}",
                               deadline: DateTime.current,
                               status: status,
                               quarter_id: Quarter.ids.sample)
    end
  end
end

def make_submissions
  students = User.where(student: true).all
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
      if [true, false].sample
        sub.update_attributes(resume_file_name: "res2.pdf",
                              resume_content_type: "application/pdf")
      end
      sub.save
    end
  end
end

def make_evaluations
end

def make_quarters
  3.times do |n|
    season = %w(winter spring summer autumn).sample
    year = 2012 + n
    Quarter.new(season: season, year: year,
               current: year == 2014 ? true : false).save
  end
end
