# frozen_string_literal: true
module SupportInterface
  class DqtRecordsController < ApplicationController
    def edit
      uuid = params[:id]
      @confirm_dqt_record_form = ConfirmDqtRecordForm.new
      @user = IdentityApi.get_user(uuid)
      @dqt_record = DqtApi.find_teacher!(date_of_birth:, trn:)
    end

    def update
      uuid = params[:id]
      @confirm_dqt_record_form =
        ConfirmDqtRecordForm.new(confirm_dqt_record_params)
      if @confirm_dqt_record_form.valid?
        if @confirm_dqt_record_form.confirmed?
          IdentityApi.update_user_trn(uuid, trn)

          flash[:success] = "DQT Record added"
        else
          flash[:notice] = "DQT Record not added"
        end

        redirect_to support_interface_identity_user_path(uuid)
      else
        @dqt_record = DqtApi.find_teacher!(date_of_birth:, trn:)
        @user = IdentityApi.get_user(uuid)
        render :edit
      end
    end

    private

    def date_of_birth
      "1990-01-01"
    end

    def trn
      "2921020"
    end

    def confirm_dqt_record_params
      params.fetch(:support_interface_confirm_dqt_record_form, {}).permit(
        :add_dqt_record,
      )
    end
  end
end
