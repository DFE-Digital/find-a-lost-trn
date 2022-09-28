# frozen_string_literal: true
module SupportInterface
  class UsersController < SupportInterfaceController
    include Pagy::Backend

    def index
      @all_users ||= IdentityApi.get_users
      @total = @all_users.size
      @pagy, @users = pagy_array(@all_users)
    end

    def show
      @user = IdentityApi.get_user(uuid)
      @dqt_record = DqtApi.find_teacher!(date_of_birth:, trn:) if @user.trn
    end

    private

    def date_of_birth
      "1990-01-01"
    end

    def trn
      "2921020"
    end

    def uuid
      params.require(:uuid)
    end
  end
end
