FactoryGirl.define do

  # has_many:   Use FactoryGirl's callbacks.
  # belongs_to: Write `thing_this_belong_to` in the belonging model.

  factory :user do
    sequence(:email) { |n| "student_#{n}@university.edu" }
    password "foobarfoo"
    password_confirmation "foobarfoo"

    factory :student do
      student true
    end

    factory :advisor do
      student true
      advisor true
    end

    factory :admin do
      student true
      admin   true
    end
  end

  factory :quarter do
    year { Date.today.year }
    season { %w(spring summer autumn winter).sample }
    current false
  end

  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    advisor_id 1
    quarter_id 1
    status "pending"
    deadline { DateTime.current }
    description { "a"*500 }
    expected_deliverables { "a"*500 }
    prerequisites { "a"*500 }
    related_work { "a"*500 }
    user
  end

  factory :submission do
    student_id 1
    project_id 1
    status "pending"
    information { "a"*500 }
    qualifications { "a"*500 }
    courses { "a"*500 }
    project
    user
  end

  factory :evaluation do
    advisor_id 1
    project_id 1
    student_id 1
    comments { "a"*500 }
    submission
  end
end
