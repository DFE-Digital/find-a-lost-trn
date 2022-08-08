class Staff::InvitationsController < Devise::InvitationsController
  layout "two_thirds"

  # GET /resource/invitation/new
  # def new
  #   super
  # end

  # POST /resource/invitation
  # def create
  #   super
  # end

  # GET /resource/invitation/accept?invitation_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/invitation
  # def update
  #   super
  # end

  # GET /resource/invitation/remove?invitation_token=abcdef
  # def destroy
  #   super
  # end

  protected

  def invite_resource(&block)
    if current_inviter.is_a?(AnonymousSupportUser)
      resource_class.invite!(invite_params, &block)
    else
      super
    end
  end
end
