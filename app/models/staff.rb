class Staff < ApplicationRecord
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

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def self.from_identity(params)
    staff = Staff.find_or_initialize_by(email: params.extra.raw_info.email)
    staff.password = Devise.friendly_token[0, 20]
    staff.skip_confirmation!
    staff.save!
    staff
  end
end
