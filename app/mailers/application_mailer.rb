# frozen_string_literal: true
class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = "458c699f-a15a-4a02-b478-fe458b8a0496"

  def notify_email(headers)
    headers =
      headers.merge(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end
end
