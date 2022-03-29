# frozen_string_literal: true
class TeacherMailer < ApplicationMailer
  layout 'teacher_email'

  def found_trn(trn_request)
    @trn_request = trn_request

    mailer_options = { to: @trn_request.email, subject: "Your TRN is #{@trn_request.trn}" }

    notify_email(mailer_options)
  end
end
