# frozen_string_literal: true
module LogErrors
  extend ActiveSupport::Concern

  included do
    def log_errors
      error_messages =
        errors.messages.to_h do |field, messages|
          [field, { messages:, value: public_send(field) }]
        end
      ValidationError.create!(
        form_object: self.class.name,
        messages: error_messages,
        trn_request:,
      )
    end
  end
end
