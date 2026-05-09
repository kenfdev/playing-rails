# typed: false

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password" }
    role { :member }
    active { true }

    trait :member    do; role { :member }    end
    trait :recruiter do; role { :recruiter } end
    trait :admin     do; role { :admin }     end
  end
end
