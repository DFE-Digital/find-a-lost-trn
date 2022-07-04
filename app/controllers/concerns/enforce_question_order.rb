# frozen_string_literal: true
module EnforceQuestionOrder
  extend ActiveSupport::Concern

  included { before_action :redirect_by_status }

  def redirect_by_status
    redirect_to(start_url) and return if start_page_is_required?
    redirect_to(name_url) and return if trn_request.nil?
    return if current_page_is_allowed?

    expected_url = urls[status]
    redirect_to(expected_url) if expected_url && expected_url != request.url
  end

  private

  def current_page_is_allowed?
    return true if trn_request&.trn

    order = urls.keys.index(status)
    current_position = urls.values.index(request.url)
    current_position && order && current_position <= order
  end

  def start_page_is_required?
    trn_request.nil? && request.path == "/trn-request"
  end

  def trn_request
    @trn_request ||=
      TrnRequest.find_or_initialize_by(id: session[:trn_request_id])
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

  def status
    return nil unless @trn_request

    return :answers if @trn_request.email.present?
    return :email if @trn_request.trn.present?
    if (
         !@trn_request.awarded_qts.nil? && !@trn_request.awarded_qts &&
           @trn_request.itt_provider_enrolled.nil?
       ) || !@trn_request.itt_provider_enrolled.nil?
      return :email
    end
    return :itt_provider if @trn_request.awarded_qts
    return :awarded_qts unless @trn_request.has_ni_number.nil?
    return :ni_number if @trn_request.has_ni_number
    return :has_ni_number if @trn_request.date_of_birth.present?
    return :date_of_birth if @trn_request.first_name.present?

    :name
  end
end
