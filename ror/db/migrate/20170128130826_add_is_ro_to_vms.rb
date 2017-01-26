class AddIsRoToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_ro, :boolean, default: false
  end
end
