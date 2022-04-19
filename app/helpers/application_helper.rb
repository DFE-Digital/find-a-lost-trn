# frozen_string_literal: true

module ApplicationHelper
  def back_link_url(back = url_for(:back))
    return check_answers_path if session[:form_complete] && request.path != check_answers_path

    back
  end

  def pretty_ni_number(ni_number)
    ni_number.scan(/..?/).join(' ').upcase
  end

  def current_namespace
    section = request.path.split('/').second
    section == 'support' ? 'support_interface' : 'find_interface'
  end

  # S-oftly hy-phenated email
  # john     .doe     @digital     .education     .gov     .uk ->
  # john&shy;.doe&shy;@digital&shy;.education&shy;.gov&shy;.uk
  #
  # We're using `sanitize`, so `html_safe` should be okay here.
  # rubocop:disable Rails/OutputSafety
  def shy_email(email)
    sanitize(email).scan(/\W?\w+/).join('&shy;').html_safe
  end
  # rubocop:enable Rails/OutputSafety
end
