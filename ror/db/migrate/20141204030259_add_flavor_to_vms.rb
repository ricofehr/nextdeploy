class AddFlavorToVms < ActiveRecord::Migration
  def change
    add_column :vms, :flavor, :string
  end
end
