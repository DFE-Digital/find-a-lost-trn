# frozen_string_literal: true
class NameController < ApplicationController
  include EnforceQuestionOrder

  layout "two_thirds"

  def edit
    @name_form = NameForm.new(trn_request:)
  end

  def update
    @name_form = NameForm.new(name_params.merge(trn_request:))
    if @name_form.save
      next_question
    else
      render :edit
    end
  end

  private

  def name_params
    params.require(:name_form).permit(
      :first_name,
      :last_name,
      :name_changed,
      :previous_first_name,
      :previous_last_name
    )
  end
end
