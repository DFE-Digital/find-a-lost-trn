# frozen_string_literal: true

class ZendeskService
  def self.create_ticket!(trn_request)
    ticket = GDS_ZENDESK_CLIENT.ticket.create!(ticket_template(trn_request))
    trn_request.update!(zendesk_ticket_id: ticket.id)
  rescue ZendeskAPI::Error::RecordInvalid => e
    Sentry.capture_exception(e, contexts: { errors: e.errors })
    raise CreateError, "Could not create Zendesk ticket"
  rescue ZendeskAPI::Error::NetworkError => e
    Sentry.capture_exception(e, contexts: { errors: e.errors })
    raise ConnectionError, "Could not connect to Zendesk"
  end

  def self.find_ticket(id)
    GDS_ZENDESK_CLIENT.ticket.find(id:)
  end

  def self.find_ticket!(id)
    GDS_ZENDESK_CLIENT.ticket.find!(id:)
  end

  def self.find_closed_tickets_from_6_months_ago
    date = 6.months.ago.strftime("%Y-%m-%d")
    GDS_ZENDESK_CLIENT
      .zendesk_client
      .search(query: "updated<#{date} type:ticket status:closed")
      .fetch
  end

  def self.destroy_tickets!(ids)
    ZendeskAPI::Ticket.destroy_many!(GDS_ZENDESK_CLIENT.zendesk_client, ids)
  end

  def self.ticket_template(trn_request)
    {
      subject: "[Find a lost TRN] Support request from #{trn_request.name}",
      comment: {
        value:
          "A user has submitted a request to find their lost TRN. Their " \
            "information is:\n" \
            "\nName: #{trn_request.name}" \
            "\nEmail: #{trn_request.email}" \
            "\nPrevious name: #{trn_request.previous_name? ? trn_request.previous_name : "None"}" \
            "\nDate of birth: #{trn_request.date_of_birth.strftime("%d %B %Y")}" \
            "\nNI number: #{trn_request.ni_number || "Not provided"}" \
            "\nITT provider: #{trn_request.itt_provider_name || "Not provided"}\n"
      },
      requester: {
        email: trn_request.email,
        name: trn_request.name
      },
      custom_fields: {
        id: "4419328659089",
        value: "request_from_find_a_lost_trn_app"
      }
    }
  end

  class ConnectionError < StandardError
  end

  class CreateError < StandardError
  end

  class ZendeskOffError < StandardError
  end
end
