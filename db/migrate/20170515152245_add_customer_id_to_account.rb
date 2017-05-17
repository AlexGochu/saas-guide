class AddCustomerIdToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :customer_id, :string
  end
end
