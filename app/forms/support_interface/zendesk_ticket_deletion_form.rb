module SupportInterface
  class ZendeskTicketDeletionForm
    include ActiveModel::Model

    attr_accessor :actual_number_of_tickets, :number_of_tickets

    validates :number_of_tickets,
              comparison: {
                equal_to: :actual_number_of_tickets,
              }
  end
end
