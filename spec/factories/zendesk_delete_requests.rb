# frozen_string_literal: true

# == Schema Information
#
# Table name: zendesk_delete_requests
#
#  id                 :bigint           not null, primary key
#  closed_at          :datetime         not null
#  enquiry_type       :string
#  group_name         :string           not null
#  no_action_required :string
#  received_at        :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ticket_id          :integer          not null
#
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
