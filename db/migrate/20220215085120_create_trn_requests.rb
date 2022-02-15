# frozen_string_literal: true
class CreateTrnRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :trn_requests, &:timestamps
  end
end
