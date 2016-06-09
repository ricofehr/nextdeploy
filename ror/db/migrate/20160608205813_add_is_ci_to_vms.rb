class AddIsCiToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_ci, :boolean, default: false
  end
end
