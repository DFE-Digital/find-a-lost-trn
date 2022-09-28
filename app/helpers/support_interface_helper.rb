# frozen_string_literal: true

module SupportInterfaceHelper
  def user_info_link(user)
    govuk_link_to(
      user.full_name,
      support_interface_identity_user_path(uuid: user.uuid),
    )
  end

  def user_verification_status(user)
    if user.name_verified?
      govuk_tag(colour: "green", text: "VERIFIED")
    else
      govuk_tag(colour: "grey", text: "UNVERIFIED")
    end
  end

  def user_dqt_record_status(user)
    if user.trn
      tag.span("Yes")
    else
      link =
        govuk_link_to(
          "(Add a DQT record)",
          edit_support_interface_dqt_record_path(user.uuid),
        )
      "#{tag.span("No")} #{link}".html_safe
    end
  end
end
