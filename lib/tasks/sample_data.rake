require 'faker'

namespace :db do
  desc "Fill database with sample data"

  task populate: :environment do
    
    delete_submissions
    delete_projects
    delete_users
    
    make_users
    make_projects
    make_submissions
    
  end
end

def delete_users
  User.delete_all
  ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'users'")
end

def delete_projects
  Project.delete_all
  ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'projects'")
end

def delete_submissions
  Submission.delete_all
  ActiveRecord::Base.connection.execute("DELETE from sqlite_sequence where name = 'submissions'")
end

def make_users

  # Create admin users
  2.times do |n|
    # name = "Admin Number #{n+1}"
    email = "admin-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password,
                 password_confirmation: password, role: "admin")
  end

  # Create advisor users
  10.times do |n|
    # name = "Advisor Number #{n+1}"
    email = "advisor-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password,
                 password_confirmation: password, role: "advisor")
  end

  # Create student users
  200.times do |n|
    # name = "Student Number #{n+1}"
    email = "student-#{n+1}@blah.org"
    password = "foobarfoo"
    User.create!(email: email, password: password,
                 password_confirmation: password, role: "student")
  end
  
end

def make_projects
  advisors = User.find_all_by_role("advisor")
  x = -1
  advisors.each do |advisor|
    x += 1
    20.times do |n|
      content = Faker::Lorem.sentence(20)
      advisor.projects.create!(description: content,
                               advisor_id: advisor.id,
                               name: "Some Project #{20*x + n + 1}",
                               deadline: Date.today,
                               approved: (1 == rand(2) ? true : false) )
    end
  end
end

def make_submissions
  students = User.find_all_by_role("student")
  students.each do |student|
    content = Faker::Lorem.sentence(20)
    student.submissions.create!(information: content,
                                student_id: student.id,
                                project_id: student.id)
  end
end
