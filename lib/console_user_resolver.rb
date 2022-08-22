class ConsoleUserResolver
  include ActiveModel::Model

  attr_accessor :email

  def current
    puts "Loading user for #{email}"
    email
  end
end
