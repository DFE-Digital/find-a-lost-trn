# frozen_string_literal: true
class TeacherMailer < ApplicationMailer
  layout "teacher_email"

  def found_trn(trn_request)
    @trn_request = trn_request

    mailer_options = {
      to: @trn_request.email,
      subject: "Your TRN is #{@trn_request.trn}",
    }

    notify_email(mailer_options)
  end

  def information_received(trn_request)
    @trn_request = trn_request

    mailer_options = {
      to: @trn_request.email,
      subject: "We’ve received the information you submitted",
    }

    notify_email(mailer_options)
  end

  def delayed_information_received(trn_request)
    @trn_request = trn_request

    mailer_options = {
      to: @trn_request.email,
      subject: "We’ve received the information you submitted",
    }

    notify_email(mailer_options)
  end
end
