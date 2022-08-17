# == Schema Information
#
# Table name: deleted_zendesk_tickets
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
class DeletedZendeskTicket < ApplicationRecord
end
