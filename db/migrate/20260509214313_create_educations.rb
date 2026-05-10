class CreateEducations < ActiveRecord::Migration[8.1]
  def change
    create_table :educations do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :school, null: false
      t.string :degree
      t.string :field
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
