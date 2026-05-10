# typed: false

FactoryBot.define do
  factory :profile do
    user
    name     { "Member Name" }
    headline { "Software engineer" }
    bio      { "Short bio." }
  end

  factory :work_history do
    profile
    company    { "Acme Corp" }
    title      { "Senior Engineer" }
    start_date { Date.new(2020, 1, 1) }
    end_date   { nil }
    description { "Built things." }
  end

  factory :education do
    profile
    school     { "State University" }
    degree     { "BSc" }
    field      { "Computer Science" }
    start_date { Date.new(2014, 9, 1) }
    end_date   { Date.new(2018, 6, 1) }
  end

  factory :skill do
    profile
    sequence(:name) { |n| "Skill #{n}" }
  end
end
