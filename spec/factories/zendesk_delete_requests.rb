# frozen_string_literal: true
FactoryBot.define do
  factory :zendesk_delete_request do
    closed_at { 27.weeks.ago }
    enquiry_type { "trn" }
    group_name { "QTS Enquiries" }
    no_action_required { nil }
    received_at { 28.weeks.ago }
    ticket_id { 42 }
  end
end
