class AddIsHtToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_ht, :boolean, default: false
  end
end
