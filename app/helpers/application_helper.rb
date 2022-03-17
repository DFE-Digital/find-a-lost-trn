# frozen_string_literal: true

module ApplicationHelper
  def back_link_url(back = url_for(:back))
    return check_answers_path if session[:form_complete]

    back
  end

  def pretty_ni_number(ni_number)
    ni_number.scan(/..?/).join(' ').upcase
  end

  def current_namespace
    section = request.path.split('/').second
    section == 'support' ? 'support_interface' : 'find_interface'
  end
end
