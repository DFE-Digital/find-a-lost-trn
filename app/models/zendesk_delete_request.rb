# == Schema Information
#
# Table name: zendesk_delete_requests
#
#  id                 :bigint           not null, primary key
#  closed_at          :datetime         not null
#  enquiry_type       :string
#  group_name         :string
#  no_action_required :string
#  received_at        :datetime         not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ticket_id          :integer          not null
#

require "csv"

class ZendeskDeleteRequest < ApplicationRecord
  ENQUIRY_TYPE_FIELD_ID = 4_419_328_659_089
  NO_ACTION_REQUIRED_FIELD_ID = 4_562_126_876_049

  scope :duplicate_ids,
        -> { select("MAX(id) as id").group(:ticket_id).having("count(*) > 1") }
  scope :no_duplicates, -> { where.not(id: duplicate_ids) }

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
    self.group_name = ticket.group&.name
    self
  end

  def self.to_csv(scope = no_duplicates)
    CSV.generate(headers: true) do |csv|
      csv << %w[
        ticket_id
        group_name
        received_at
        closed_at
        enquiry_type
        no_action_required
      ].map(&:titleize)

      scope.find_each do |request|
        csv << [
          request.ticket_id,
          request.group_name,
          request.received_at.in_time_zone("London").strftime("%Y-%m-%d %H:%M"),
          request.closed_at.in_time_zone("London").strftime("%Y-%m-%d %H:%M"),
          request.enquiry_type&.titleize,
          request.no_action_required == "t" ? "No action required" : nil,
        ]
      end
    end
  end

  def self.from_csv(csv)
    CSV.foreach(csv.path, headers: true) do |row|
      find_or_create_by(
        closed_at: row["Closed At"],
        enquiry_type: row["Enquiry Type"],
        group_name: row["Group Name"],
        no_action_required: row["No Action Required"],
        received_at: row["Received At"],
        ticket_id: row["Ticket"],
      )
    end
  end
end
