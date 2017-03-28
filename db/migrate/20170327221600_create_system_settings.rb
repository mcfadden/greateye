class CreateSystemSettings < ActiveRecord::Migration
  def change
    create_table :system_settings do |t|
      t.string :name
      t.integer :value_type, default: 0, null: false
      t.boolean :bool_value
      t.string :string_value
      t.integer :integer_value

      t.timestamps null: false
    end
    add_index :system_settings, :name
  end
end
