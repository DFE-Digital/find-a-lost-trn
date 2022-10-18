# frozen_string_literal: true
class PreferredNameController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
    @preferred_name_form = PreferredNameForm.new(trn_request:)
  end

  def update
    @preferred_name_form = PreferredNameForm.new(preferred_name_params.merge(trn_request:))
    if @preferred_name_form.save!
      next_question
    else
      render :edit
    end
  end

  private

  def preferred_name_params
    params.require(:preferred_name_form).permit(
      :official_name_is_preferred,
      :preferred_first_name,
      :preferred_last_name,
    )
  end
end
