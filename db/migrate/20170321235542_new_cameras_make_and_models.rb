class NewCamerasMakeAndModels < ActiveRecord::Migration
  def change
    remove_column :cameras, :model
    add_column :cameras, :make, :string
    add_column :cameras, :model, :string
    add_index :cameras, [:make, :model]
  end
end
