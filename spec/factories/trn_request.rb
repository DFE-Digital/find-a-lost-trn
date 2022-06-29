# frozen_string_literal: true
FactoryBot.define do
  factory :trn_request do
    email { Faker::Internet.email }
    date_of_birth { Faker::Date.between(from: 70.years.ago, to: 18.years.ago) }
    has_ni_number { false }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    trait :has_ni_number do
      has_ni_number { true }
      ni_number { "QQ123456C" }
    end

    trait :has_itt_provider do
      itt_provider_enrolled { true }
      itt_provider_name { Faker::Educator.university }
    end

    trait :has_previous_name do
      previous_first_name { Faker::Name.first_name }
      previous_last_name { Faker::Name.last_name }
    end

    trait :has_trn do
      checked_at { Faker::Date.backward(days: 14) }
      trn { Faker::Number.number(7) }
    end

    trait :has_zendesk_ticket do
      checked_at { Faker::Date.backward(days: 14) }
      trn { nil }
      zendesk_ticket_id { Faker::Number.number(digits: 4) }
    end
  end
end
