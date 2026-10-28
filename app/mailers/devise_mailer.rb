class DeviseMailer < Devise::Mailer
  GOVUK_NOTIFY_TEMPLATE_ID =
    ENV.fetch(
      "GOVUK_NOTIFY_TEMPLATE_ID_DEVISE",
      "458c699f-a15a-4a02-b478-fe458b8a0496",
    )

  # mail-notify 2 renders the body with a bare `mail` call, which ignores the
  # template_path Devise passes in headers_for, so set the staff scope's views
  # as the default.
  default template_path: "staff/mailer"

  def devise_mail(record, action, opts = {}, &_block)
    initialize_from_record(record)
    view_mail(GOVUK_NOTIFY_TEMPLATE_ID, headers_for(action, opts))
  end
end
