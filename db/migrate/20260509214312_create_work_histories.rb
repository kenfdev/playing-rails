class CreateWorkHistories < ActiveRecord::Migration[8.1]
  def change
    create_table :work_histories do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :company, null: false
      t.string :title, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.text :description

      t.timestamps
    end
  end
end
