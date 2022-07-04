class HasNiNumberController < ApplicationController
  include EnforceQuestionOrder

  def edit
    @has_ni_number_form = HasNiNumberForm.new(trn_request:)
  end

  def update
    @has_ni_number_form = HasNiNumberForm.new(trn_request:)
    if @has_ni_number_form.update(has_ni_number_params)
      redirect_to @trn_request.has_ni_number? ? ni_number_url : awarded_qts_url
    else
      render :edit
    end
  end

  private

  def has_ni_number_params
    params.require(:has_ni_number_form).permit(:has_ni_number)
  end
end
