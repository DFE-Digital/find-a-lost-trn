# frozen_string_literal: true
class NoMatchController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def new
    @no_match_form = NoMatchForm.new
  end

  def create
    @no_match_form = NoMatchForm.new(no_match_params)
    if @no_match_form.valid? && @no_match_form.try_again?
      redirect_to check_answers_path
    elsif @no_match_form.valid?
      create_zendesk_ticket

      redirect_to helpdesk_request_submitted_path
    else
      render :new
    end
  end

  private

  def no_match_params
    params.require(:no_match_form).permit(:try_again)
  end

  def create_zendesk_ticket
    ZendeskService.create_ticket!(trn_request)
    TeacherMailer.information_received(trn_request).deliver_later
    CheckZendeskTicketForTrnJob.set(wait: 2.days).perform_later(trn_request.id)
  end
end
