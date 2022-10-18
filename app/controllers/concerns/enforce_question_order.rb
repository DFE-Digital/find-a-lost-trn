# frozen_string_literal: true
module EnforceQuestionOrder
  extend ActiveSupport::Concern

  included { before_action :redirect_to_next_question }

  def redirect_to_next_question
    if request_from_identity_and_complete?
      redirect_to session[:identity_redirect_url], allow_other_host: true
      return
    end
    redirect_to(start_url) and return if start_page_is_required?
    return if all_questions_answered?
    return if previous_questions_answered?

    redirect_to next_question_path if request.path != next_question_path
  end

  def next_question
    session[:trn_request_id] ||= trn_request.reload.id

    redirect_to next_question_path
  end

  def redirect_requests_from_identity
    redirect_to next_question_path if request_from_identity?
  end

  def request_from_identity_and_complete?
    session[:identity_redirect_url] && request_from_identity? &&
      session[:identity_trn_request_sent]
  end

  private

  def trn_request
    @trn_request ||=
      TrnRequest.find_or_initialize_by(id: session[:trn_request_id])
  end

  def start_page_is_required?
    trn_request.nil? && request.path == "/trn-request"
  end

  def request_from_identity?
    trn_request.from_get_an_identity? || request.path == "/identity"
  end

  def questions
    [
      { path: email_path, needs_answer: ask_for_email? },
      { path: name_path, needs_answer: ask_for_name? },
      { path: preferred_name_path, needs_answer: ask_for_preferred_name? },
      { path: date_of_birth_path, needs_answer: ask_for_date_of_birth? },
      { path: have_ni_number_path, needs_answer: ask_if_has_ni_number? },
      { path: ni_number_path, needs_answer: ask_for_ni_number? },
      { path: ask_trn_path, needs_answer: ask_for_trn? },
      { path: awarded_qts_path, needs_answer: ask_if_awarded_qts? },
      { path: itt_provider_path, needs_answer: ask_for_itt_provider? },
    ]
  end

  def next_question_path
    questions.each { |q| return q[:path] if q[:needs_answer] }

    check_answers_path
  end

  def all_questions_answered?
    questions.none? { |q| q[:needs_answer] }
  end

  def previous_questions_answered?
    requested_question_index =
      questions.find_index { |q| q[:path] == request.path }

    path_is_not_a_question = requested_question_index.nil?
    return false if path_is_not_a_question

    is_first_question = requested_question_index.zero?
    return true if is_first_question

    previous_questions = questions[0...requested_question_index]
    previous_questions.all? { |q| q[:needs_answer] == false }
  end

  def ask_for_name?
    trn_request.first_name.nil?
  end

  def ask_for_preferred_name?
    return false unless trn_request.from_get_an_identity?

    trn_request.preferred_first_name.nil?
  end

  def ask_for_date_of_birth?
    trn_request.date_of_birth.nil?
  end

  def ask_if_has_ni_number?
    return false if trn_request.trn

    trn_request.has_ni_number.nil?
  end

  def ask_for_ni_number?
    return false if session[:ni_number_not_known]

    trn_request.has_ni_number && trn_request.ni_number.nil?
  end

  def ask_for_trn?
    return false unless trn_request.from_get_an_identity

    return false if trn_request.trn

    trn_request.trn_from_user.nil?
  end

  def ask_if_awarded_qts?
    return false if trn_request.trn

    trn_request.awarded_qts.nil?
  end

  def ask_for_itt_provider?
    trn_request.awarded_qts && trn_request.itt_provider_enrolled.nil?
  end

  def ask_for_email?
    trn_request.email.nil? && !trn_request.from_get_an_identity?
  end
end
