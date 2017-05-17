class CreatePlans < ActiveRecord::Migration[5.0]
  def change
    create_table :plans do |t|
      t.string :stripe_id
      t.string :name
      t.integer :price
      t.string :intervel

      t.timestamps
    end
  end
end
