# frozen_string_literal: true
module SupportInterface
  class UsersController < SupportInterfaceController
    include Pagy::Backend
    include ConsumesIdentityUsersApi

    layout "two_thirds", only: %i[edit update]

    def index
      @all_users ||= identity_users_api.get_users
      @total = @all_users.size
      @pagy, @users = pagy_array(@all_users)
    end

    def show
      @user = identity_users_api.get_user(uuid)
      @dqt_record = DqtApi.find_teacher_by_trn!(trn: @user.trn) if @user.trn
    end

    def edit
      @trn_form = TrnForm.new
      @uuid = uuid
    end

    def update
      @trn_form = TrnForm.new(import_params)
      if @trn_form.save
        @confirm_dqt_record_form = ConfirmDqtRecordForm.new(trn: @trn_form.trn)
        @user = identity_users_api.get_user(uuid)
        @dqt_record = DqtApi.find_teacher_by_trn!(trn: @trn_form.trn)

        render "support_interface/dqt_records/edit",
               id: uuid,
               trn: @trn_form.trn
      else
        @uuid = uuid
        render :edit
      end
    rescue DqtApi::NoResults
      flash[:notice] = "TRN does not exist"
      redirect_to edit_support_interface_identity_user_path(uuid)
    end

    private

    def uuid
      params.require(:id)
    end

    def import_params
      params.require(:support_interface_trn_form).permit(:trn)
    end
  end
end
