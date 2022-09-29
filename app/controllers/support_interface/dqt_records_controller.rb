# frozen_string_literal: true
module SupportInterface
  class DqtRecordsController < ApplicationController
    def edit
      @confirm_dqt_record_form = ConfirmDqtRecordForm.new(trn:)
      @user = IdentityApi.get_user(uuid)
      @dqt_record = DqtApi.find_teacher_by_trn!(trn:)
    rescue DqtApi::NoResults
      flash[:notice] = "TRN does not exist"
      redirect_to edit_support_interface_identity_user_path(uuid)
    end

    def update
      @confirm_dqt_record_form =
        ConfirmDqtRecordForm.new(confirm_dqt_record_params)
      if @confirm_dqt_record_form.valid?
        if @confirm_dqt_record_form.confirmed?
          IdentityApi.update_user_trn(uuid, @confirm_dqt_record_form.trn)

          flash[:success] = "DQT Record added"
        else
          flash[:notice] = "DQT Record not added"
        end

        redirect_to support_interface_identity_user_path(uuid)
      else
        @dqt_record =
          DqtApi.find_teacher_by_trn!(trn: @confirm_dqt_record_form.trn)
        @user = IdentityApi.get_user(uuid)
        render :edit
      end
    end

    private

    def uuid
      params.require(:id)
    end

    def trn
      params.require(:trn)
    end

    def confirm_dqt_record_params
      params.fetch(:support_interface_confirm_dqt_record_form, {}).permit(
        :add_dqt_record,
        :trn,
      )
    end
  end
end
