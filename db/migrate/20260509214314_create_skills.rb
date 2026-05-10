class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills do |t|
      t.references :profile, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position

      t.timestamps
    end
    add_index :skills, [ :profile_id, :name ], unique: true
  end
end
