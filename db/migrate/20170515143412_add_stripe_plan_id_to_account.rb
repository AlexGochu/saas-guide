class AddStripePlanIdToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :stripe_plan_id, :string
  end
end
