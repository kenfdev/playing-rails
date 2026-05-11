class CreateSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :salaries do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.integer :current_amount
      t.integer :expected_min
      t.integer :expected_max

      t.timestamps
    end
  end
end
