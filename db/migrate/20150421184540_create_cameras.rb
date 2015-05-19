class CreateCameras < ActiveRecord::Migration
  def change
    create_table :cameras do |t|
      t.string :name
      t.integer :model, default: 0
      t.string :username
      t.string :password
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
