# frozen_string_literal: true

class RemoveAccountLockingFeatureFlag < ActiveRecord::Migration[7.2]
  def up
    Feature.where(name: :unlock_teachers_self_service_portal_account).destroy_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
