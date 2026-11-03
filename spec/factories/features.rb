FactoryBot.define do
  factory :feature do
    name { "feature" }
    active { false }

    trait :active do
      active { true }
    end
  end
end
