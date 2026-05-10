class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills do |t|
      t.references :profile, null: false, foreign_key: true, index: false
      t.string :name, null: false
      t.string :name_normalized, null: false

      t.timestamps
    end
    add_index :skills, [ :profile_id, :name_normalized ], unique: true
  end
end
