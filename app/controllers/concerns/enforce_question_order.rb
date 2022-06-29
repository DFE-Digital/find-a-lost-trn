# frozen_string_literal: true
module EnforceQuestionOrder
  extend ActiveSupport::Concern

  included { before_action :redirect_by_status }

  def redirect_by_status
    redirect_to(start_url) and return if start_page_is_required?
    redirect_to(name_url) and return if trn_request.nil?
    return if current_page_is_allowed?

    expected_url = urls[trn_request.status]
    redirect_to(expected_url) if expected_url && expected_url != request.url
  end

  private

  def current_page_is_allowed?
    return true if trn_request&.trn

    order = urls.keys.index(trn_request&.status)
    current_position = urls.values.index(request.url)
    current_position && order && current_position <= order
  end

  def start_page_is_required?
    trn_request.nil? && request.path == "/trn-request"
  end

  def trn_request
    @trn_request ||= TrnRequest.find_by(id: session[:trn_request_id])
  end

  def urls
    {
      name: name_url,
      date_of_birth: date_of_birth_url,
      has_ni_number: have_ni_number_url,
      ni_number: ni_number_url,
      awarded_qts: awarded_qts_url,
      itt_provider: itt_provider_url,
      email: email_url
    }
  end
end
