# == Schema Information
#
# Table name: staff
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  uid                    :string
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  invited_by_id          :bigint
#
# Indexes
#
#  index_staff_on_confirmation_token    (confirmation_token) UNIQUE
#  index_staff_on_email                 (email) UNIQUE
#  index_staff_on_invitation_token      (invitation_token) UNIQUE
#  index_staff_on_invited_by            (invited_by_type,invited_by_id)
#  index_staff_on_invited_by_id         (invited_by_id)
#  index_staff_on_provider_and_uid      (provider,uid) UNIQUE
#  index_staff_on_reset_password_token  (reset_password_token) UNIQUE
#  index_staff_on_unlock_token          (unlock_token) UNIQUE
#
class Staff < ApplicationRecord
  class IdentityEmailConflictError < StandardError
    attr_reader :uid, :existing_staff_uid

    def initialize(uid:, existing_staff_uid:)
      @uid = uid # uid sent by the identity provider
      @existing_staff_uid = existing_staff_uid # uid on the staff record already in the FLTRN db
      super("Identity uid conflicts with an existing staff record")
    end
  end

  class IdentityMissingUidError < StandardError; end

  devise :confirmable,
         :database_authenticatable,
         :invitable,
         :lockable,
         :omniauthable,
         :recoverable,
         :rememberable,
         :timeoutable,
         :trackable,
         :validatable

  def self.from_identity(params)
    uid = params.uid
    provider = params.provider
    email = params.info.email&.downcase
    if uid.blank?
      raise IdentityMissingUidError, "Identity auth response is missing a uid"
    end

    staff = find_by(provider:, uid:) ||
            find_by(email:, uid: nil, provider: nil) ||
            new
    staff.assign_attributes(provider:, uid:, email:)

    existing_staff = where(email:).where.not(id: staff.id).first
    if existing_staff
      raise IdentityEmailConflictError.new(uid:, existing_staff_uid: existing_staff.uid)
    end

    staff.password = Devise.friendly_token[0, 20]
    staff.skip_confirmation!
    staff.skip_reconfirmation! # skip reconfirmation on email changes, identity is trusted
    staff.save!
    staff
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
