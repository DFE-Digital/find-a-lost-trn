# frozen_string_literal: true
module EmailHelper
  def back_link_url(trn_request)
    referer = controller.request.env['HTTP_REFERER']
    return check_answers_path if referer&.include?('check-answers') || trn_request&.email?

    start_path
  end
end
