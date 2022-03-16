# frozen_string_literal: true

module ApplicationHelper
  def back_link_url
    return url_for(:back) unless url_for(:back).include?(request.path)

    'javascript:history.go(-2)'
  end

  def pretty_ni_number(ni_number)
    ni_number.scan(/..?/).join(' ').upcase
  end

  def current_namespace
    section = request.path.split('/').second
    section == 'support' ? 'support_interface' : 'find_interface'
  end
end
