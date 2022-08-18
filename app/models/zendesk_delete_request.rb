# == Schema Information
#
# Table name: zendesk_delete_requests
#
#  id                 :bigint           not null, primary key
#  closed_at          :datetime         not null
#  enquiry_type       :string           not null
#  group_name         :string           not null
#  no_action_required :string           not null
#  received_at        :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ticket_id          :integer          not null
#
class ZendeskDeleteRequest < ApplicationRecord
  ENQUIRY_TYPE_FIELD_ID = 4_419_328_659_089
  NO_ACTION_REQUIRED_FIELD_ID = 4_562_126_876_049

  def from(ticket)
    self.ticket_id = ticket.id
    self.received_at = ticket.created_at
    self.closed_at = ticket.updated_at
    self.enquiry_type =
      ticket
        .custom_fields
        .find { |field| field.id == ENQUIRY_TYPE_FIELD_ID }
        .value
    self.no_action_required =
      ticket
        .custom_fields
        .find { |field| field.id == NO_ACTION_REQUIRED_FIELD_ID }
        .value
    self.group_name = ticket.group.name
    self
  end
end
