class AddIttProviderUkprnToTrnRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :trn_requests, :itt_provider_ukprn, :string
  end
end
