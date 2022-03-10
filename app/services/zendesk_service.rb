# frozen_string_literal: true
class ZendeskService
  def self.create_ticket!(trn_request)
    return unless FeatureFlag.active?(:zendesk_integration)

    begin
      GDS_ZENDESK_CLIENT.ticket.create!(ticket_template(trn_request))
    rescue ZendeskAPI::Error::RecordInvalid
      raise CreateError, 'Could not create Zendesk ticket'
    end
  end

  def self.ticket_template(trn_request)
    {
      subject: "[Find a lost TRN] Support request from #{trn_request.name}",
      comment: {
        value:
          'A user has submitted a request to find their lost TRN. Their ' \
            "information is:\n" \
            "\nName: #{trn_request.name}" \
            "\nDate of birth: #{trn_request.date_of_birth.strftime('%d %B %Y')}" \
            "\nNI number: #{trn_request.ni_number || 'Not provided'}" \
            "\nITT provider: #{trn_request.itt_provider_name || 'Not provided'}\n",
      },
    }
  end

  class CreateError < StandardError
  end
end
