class CreateProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :name
      t.string :headline
      t.text :bio
      t.datetime :profile_updated_at

      t.timestamps
    end
  end
end
