class User
  attr_reader :first_name,
              :last_name,
              :email,
              :date_of_birth,
              :uuid,
              :trn,
              :name_verified

  def initialize(attributes = {})
    @first_name = attributes.fetch("firstName", nil)
    @last_name = attributes.fetch("lastName", nil)
    @email = attributes.fetch("email", nil)
    @date_of_birth = attributes.fetch("dateOfBirth", nil)
    @uuid = attributes.fetch("userId", nil)
    @trn = attributes.fetch("trn", nil)
    @name_verified = attributes.fetch("nameVerified", false)
  end

  def full_name
    [first_name, last_name].join(" ")
  end

  def name_verified?
    name_verified
  end
end
