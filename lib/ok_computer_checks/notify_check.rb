module OkComputerChecks
  class NotifyCheck < OkComputer::Check
    TEST_EMAIL = "simulate-delivered@notifications.service.gov.uk".freeze

    def check
      client = Notifications::Client.new(ENV.fetch("GOVUK_NOTIFY_API_KEY"))
      client.send_email(
        email_address: TEST_EMAIL,
        personalisation: {
          body: "Test",
          subject: "Test",
        },
        template_id: ApplicationMailer::GENERIC_NOTIFY_TEMPLATE,
      )
      mark_message "Notify is connected"
    rescue StandardError => e
      mark_failure
      mark_message e.message
    end
  end
end
