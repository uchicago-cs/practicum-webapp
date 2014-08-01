FactoryGirl.define do

  # has_many:   Use FactoryGirl's callbacks.
  # belongs_to: Write `thing_this_belong_to` in the belonging model.

  factory :user do
    sequence(:email) { |n| "user_#{n}@university.edu" }
    password "foobarfoo"
    password_confirmation "foobarfoo"

    trait :student do
      sequence(:email) { |n| "student_#{n}@university.edu" }
      student true
    end

    trait :advisor do
      sequence(:email) { |n| "advisor_#{n}@university.edu" }
      student true
      advisor true
    end

    trait :admin do
      sequence(:email) { |n| "admin_#{n}@university.edu" }
      student true
      admin   true
    end

    factory :student, traits: [:student]
    factory :advisor, traits: [:advisor]
    factory :admin,   traits: [:admin]
  end

  factory :quarter do
    year { Date.today.year }
    season { %w(spring summer autumn winter).sample }
    current false
  end

  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:advisor_id) { |n| n }
    sequence(:quarter_id) { |n| n }
    status "pending"
    deadline { DateTime.current }
    description { "a"*500 }
    expected_deliverables { "a"*500 }
    prerequisites { "a"*500 }
    related_work { "a"*500 }
    # `user`s should _not_ be allowed to create projects!
    association :user, factory: [:user, :advisor]
  end

  factory :submission do
    sequence(:student_id) { |n| n }
    sequence(:project_id) { |n| n }
    status "pending"
    information { "a"*500 }
    qualifications { "a"*500 }
    courses { "a"*500 }
    project
    # `user`s should _not_ be allowed to create submissions!
    association :user, factory: [:user, :student]
  end

  factory :evaluation do
    sequence(:advisor_id) { |n| n }
    sequence(:project_id) { |n| n }
    sequence(:student_id) { |n| n }
    comments { "a"*500 }
    submission
  end
end
