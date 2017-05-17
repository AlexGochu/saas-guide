class AddActiveUntilToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :active_until, :datetime
  end
end
