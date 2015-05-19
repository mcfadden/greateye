class AddHostToCamera < ActiveRecord::Migration
  def change
    add_column :cameras, :host, :string
  end
end
