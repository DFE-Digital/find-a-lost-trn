# frozen_string_literal: true
module EnforceQuestionOrder
  extend ActiveSupport::Concern

  included { before_action :redirect_to_next_question }

  def redirect_to_next_question
    redirect_to(start_url) and return if start_page_is_required?
    return if all_questions_answered?
    return if previous_question_answered?

    redirect_to next_question_path if request.path != next_question_path
  end

  def next_question
    session[:trn_request_id] ||= trn_request.reload.id

    redirect_to next_question_path
  end

  private

  def trn_request
    @trn_request ||=
      TrnRequest.find_or_initialize_by(id: session[:trn_request_id])
  end

  def start_page_is_required?
    trn_request.nil? && request.path == "/trn-request"
  end

  def questions
    [
      { path: email_path, needs_answer: ask_for_email? },
      { path: name_path, needs_answer: ask_for_name? },
      { path: date_of_birth_path, needs_answer: ask_for_date_of_birth? },
      { path: have_ni_number_path, needs_answer: ask_if_has_ni_number? },
      { path: ni_number_path, needs_answer: ask_for_ni_number? },
      { path: awarded_qts_path, needs_answer: ask_if_awarded_qts? },
      { path: itt_provider_path, needs_answer: ask_for_itt_provider? }
    ]
  end

  def next_question_path
    questions.each { |q| return q[:path] if q[:needs_answer] }

    check_answers_path
  end

  def all_questions_answered?
    questions.none? { |q| q[:needs_answer] }
  end

  def previous_question_answered?
    requested_question_index =
      questions.find_index { |q| q[:path] == request.path }

    path_is_not_a_question = requested_question_index.nil?
    return false if path_is_not_a_question

    is_first_question = requested_question_index.zero?
    return true if is_first_question

    previous_question = questions[requested_question_index - 1]

    previous_question[:needs_answer] == false
  end

  def ask_for_name?
    trn_request.first_name.nil?
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

  def ask_if_awarded_qts?
    return false if trn_request.trn

    trn_request.awarded_qts.nil?
  end

  def ask_for_itt_provider?
    trn_request.awarded_qts && trn_request.itt_provider_enrolled.nil?
  end

  def ask_for_email?
    trn_request.email.nil?
  end
end
