FactoryGirl.define do

  # has_many:   Use FactoryGirl's callbacks.
  # belongs_to: Write `thing_this_belong_to` in the belonging model.

  factory :user, class: LdapUser do
    sequence(:email)      { |n| "user_#{n}@university.edu" }
    sequence(:first_name) { |n| "User" }
    sequence(:last_name)  { |n| "#{n}" }
    sequence(:cnet)       { |n| "user#{n}" }
    password              "foobarfoo"
    password_confirmation "foobarfoo"

    trait :student do
      sequence(:email) { |n| "student_#{n}@university.edu" }
      student true
    end

    trait :advisor do
      sequence(:email) { |n| "advisor_#{n}@university.edu" }
      student false
      advisor true
    end

    trait :admin do
      sequence(:email) { |n| "admin_#{n}@university.edu" }
      student false
      admin   true
    end

    trait :guest do
      student false
    end

    factory :student, traits: [:student]
    factory :advisor, traits: [:advisor]
    factory :admin,   traits: [:admin]
    factory :guest,   traits: [:guest]
  end

  factory :quarter do
    # Not DRY
    season_dates = { "spring" => "4th Monday in March",
                     "summer" => "4th Monday in June",
                     "autumn" => "4th Monday in September",
                     "winter" => "1st Monday in January" }
    deadline_weeks = { "proposal" => 2, "submission" => 5, "decision" => 7,
                       "admin" => 8 }

    year { Date.today.year }
    season { %w(spring summer autumn winter)[((Time.now.month - 1) / 3)-1] }
    start_date { Chronic.parse(season_dates[season.downcase],
                 now: Time.local(year, 1, 1, 12, 0, 0)).to_datetime }
    project_proposal_deadline { start_date +
      deadline_weeks["proposal"].weeks + 4.days + 5.hours }
    student_submission_deadline { start_date +
      deadline_weeks["submission"].weeks + 4.days + 5.hours }
    advisor_decision_deadline { start_date +
      deadline_weeks["decision"].weeks + 4.days + 5.hours }
    admin_publish_deadline { start_date +
      deadline_weeks["admin"].weeks + 4.days + 5.hours }
    end_date { start_date + 9.weeks + 5.days }

    trait :can_create_submission do
      student_submission_deadline { DateTime.tomorrow }
    end

    trait :can_create_project do
      project_proposal_deadline { DateTime.tomorrow }
    end

    trait :advisor_can_decide do
      advisor_decision_deadline { DateTime.tomorrow }
    end

    trait :cannot_create_submission do
      student_submission_deadline { DateTime.yesterday }
    end

    trait :cannot_create_project do
      project_proposal_deadline { DateTime.yesterday }
    end

    trait :advisor_cannot_decide do
      advisor_decision_deadline { DateTime.yesterday }
    end

    trait :later_end_date do
      end_date { DateTime.now + 11.weeks }
    end

    trait :earlier_start_date do
      start_date { DateTime.now - 11.weeks }
    end

    trait :no_deadlines_passed do
      can_create_submission
      can_create_project
      advisor_can_decide
      later_end_date
    end

    trait :all_deadlines_passed do
      earlier_start_date
      cannot_create_submission
      cannot_create_project
      advisor_cannot_decide
      later_end_date
    end

    trait :inactive_and_deadlines_passed do
      earlier_start_date
      end_date { start_date + 9.weeks + 5.days }
      project_proposal_deadline { start_date + 1.day }
      student_submission_deadline { start_date + 2.days }
      advisor_decision_deadline { start_date + 3.days }
      admin_publish_deadline { start_date + 4.days }
    end
  end

  factory :project do
    sequence(:name) { |n| "Project #{n}" }
    sequence(:advisor_id) { |n| n }
    sequence(:quarter_id) { |n| n }
    status "pending"
    description { "a"*500 }
    expected_deliverables { "a"*500 }
    prerequisites { "a"*500 }
    related_work { "a"*500 }
    # `user`s should _not_ be allowed to create projects!
    association :advisor, factory: [:user, :advisor]
    # quarter { Quarter.current_quarter }

    trait :accepted do
      status { "accepted" }
    end

    trait :published do
      status_published { true }
    end

    trait :accepted_and_published do
      accepted
      published
    end

    trait :in_current_quarter do
      quarter_id { Quarter.current_quarter.id }
    end
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
    association :student, factory: [:user, :student]
  end

  factory :evaluation_template do
    name "Midterm"
    survey { { 1 => { "question_prompt"    => "How are you?",
                      "question_type"      => "Text area",
                      "question_mandatory" => "1" },
               2 => { "question_prompt"    => "What's your name?",
                      "question_type"      => "Text field",
                      "question_mandatory" => "1" } } }
  end

  factory :evaluation do
    sequence(:advisor_id) { |n| n }
    sequence(:project_id) { |n| n }
    sequence(:student_id) { |n| n }
    submission
    survey { { "How are you?" => "Great!", "What's your name?" => "John Doe" } }
  end

end
