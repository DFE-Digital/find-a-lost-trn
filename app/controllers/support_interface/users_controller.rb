# frozen_string_literal: true
module SupportInterface
  class UsersController < SupportInterfaceController
    include Pagy::Backend
    include ConsumesIdentityUsersApi

    layout "two_thirds", only: %i[edit update email update_email]

    def index
      page = params[:page] || 1
      @all_users ||= identity_users_api.get_users(page:)
      @total = @all_users[:total]
      @pagy = Pagy.new(count: @total, page:)
      @users = @all_users[:users]
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

    def email
      @email_form = EmailForm.new
      @uuid = uuid
    end

    def update_email
      @email_form = EmailForm.new(email_form_params)
      if @email_form.save
        @user =
          identity_users_api.update_user(uuid, { email: @email_form.email })
        flash[:success] = "Email changed successfully"
        redirect_to support_interface_identity_user_path(uuid)
      else
        @uuid = uuid
        render :email
      end
    end

    private

    def uuid
      params.require(:id)
    end

    def import_params
      params.require(:support_interface_trn_form).permit(:trn)
    end

    def email_form_params
      params.require(:support_interface_email_form).permit(:email)
    end
  end
end
