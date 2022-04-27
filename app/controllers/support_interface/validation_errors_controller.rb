# frozen_string_literal: true
module SupportInterface
  class ValidationErrorsController < SupportInterface::SupportInterfaceController
    def index
      @validation_errors = ValidationError.group(:form_object).order('count_all DESC').count
    end

    def show
      @form_object = params[:form_object]
      @validation_errors = ValidationError.where(form_object: @form_object).order('created_at DESC')
    end
  end
end
