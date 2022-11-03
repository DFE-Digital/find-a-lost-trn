module SupportInterface
  class ChangeNameController < SupportInterfaceController
    include Pagy::Backend
    include ConsumesIdentityUsersApi

    layout "two_thirds"

    def show
      @user = identity_users_api.get_user(uuid)
      @change_name_form = ChangeNameForm.new
      @uuid = uuid
    end

    def update
      @user = identity_users_api.get_user(uuid)
      @change_name_form = ChangeNameForm.new(change_name_params)
      @uuid = uuid
      if @change_name_form.save
        @user =
          identity_users_api.update_user(
            uuid,
            {
              firstName: @change_name_form.first_name,
              lastName: @change_name_form.last_name,
            },
          )
        flash[:success] = "Name changed successfully"
        redirect_to support_interface_identity_user_path(uuid)
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def uuid
      params.require(:id)
    end

    def change_name_params
      params.require(:support_interface_change_name_form).permit(
        :first_name,
        :last_name,
      )
    end
  end
end
