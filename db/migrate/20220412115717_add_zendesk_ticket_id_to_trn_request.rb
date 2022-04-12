# frozen_string_literal: true
class AddZendeskTicketIdToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :zendesk_ticket_id, :integer
  end
end
