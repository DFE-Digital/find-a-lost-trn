# frozen_string_literal: true

# The arguments carry the monthly export CSV and Devise's raw tokens.
ActiveSupport.on_load(:action_mailer) do
  ActionMailer::MailDeliveryJob.log_arguments = false
end
