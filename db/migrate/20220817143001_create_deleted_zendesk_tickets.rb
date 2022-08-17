class CreateDeletedZendeskTickets < ActiveRecord::Migration[7.0]
  def change
    create_table :deleted_zendesk_tickets do |t|
      t.datetime :received_at, null: false
      t.datetime :closed_at, null: false
      t.integer :ticket_id, null: false
      t.string :enquiry_type, null: false
      t.string :no_action_required, null: false
      t.string :group_name, null: false

      t.timestamps
    end
  end
end
