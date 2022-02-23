# frozen_string_literal: true

module ApplicationHelper
  def back_link_url(trn_request)
    referer = controller.request.env['HTTP_REFERER']
    return check_answers_path if referer&.include?('check-answers') || trn_request&.email?

    start_path
  end

  def pretty_ni_number(ni_number)
    ni_number.scan(/..?/).join(' ').upcase
  end
end
