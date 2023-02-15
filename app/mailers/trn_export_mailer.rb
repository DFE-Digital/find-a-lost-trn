class TrnExportMailer < ApplicationMailer
  layout "mailer"

  def monthly_report(csv)
    export_template_id =
      ENV.fetch(
        "GOVUK_NOTIFY_EXPORT_TEMPLATE_ID",
        "0aefb0df-462e-44a7-8de4-f97fe00a0595",
      )

    link_to_file = Notifications.prepare_upload(StringIO.new(csv), true)

    mailer_options = {
      subject: "TRN requests export",
      to: ENV.fetch("TRN_EXPORT_RECIPIENT", "test@example.com"),
      personalisation: {
        link_to_file:,
      },
    }

    template_mail(export_template_id, mailer_options)
  end
end
