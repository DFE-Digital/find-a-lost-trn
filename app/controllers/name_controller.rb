# frozen_string_literal: true
class NameController < ApplicationController
  def edit
    @name_form = NameForm.new(trn_request: trn_request)
  end

  def update
    @name_form = NameForm.new(name_params.merge(trn_request: trn_request))
    if @name_form.save
      session[:trn_request_id] = @name_form.trn_request.id
      redirect_to trn_request.email? ? check_answers_path : date_of_birth_path
    else
      render :edit
    end
  end

  private

  def name_params
    params.require(:name_form).permit(:first_name, :previous_first_name, :previous_last_name, :last_name)
  end

  def trn_request
    @trn_request ||= TrnRequest.find_or_initialize_by(id: session[:trn_request_id])
  end
end
