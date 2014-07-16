FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "student_#{n+500}@blah.org" }
    password "foobarfoo"
    password_confirmation "foobarfoo"
  end

  factory :student do
    student true
    sequence(:email) { |n| "student_#{n+500}@blah.org" }
    password "foobarfoo"
    password_confirmation "foobarfoo"
  end

  factory :advisor do 
    advisor true
    sequence(:email) { |n| "advisor_#{n+500}@blah.org" }
    password "foobarfoo"
    password_confirmation "foobarfoo"
  end

  factory :admin do
    admin true
    sequence(:email) { |n| "admin_#{n+500}@blah.org" }
    password "foobarfoo"
    password_confirmation "foobarfoo"
  end

  factory :project do
    sequence(:name) { |n| "Project #{n+500} "}
    advisor_id 1
    status "pending"
    deadline DateTime.current
    description Faker::Lorem.sentence(20)
  end

  factory :submission do
    student_id 1
    project_id 1
    status "pending"
    information Faker::Lorem.sentence(20)
  end
end
