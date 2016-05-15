class AddIsProdToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_prod, :boolean, default: false
  end
end
