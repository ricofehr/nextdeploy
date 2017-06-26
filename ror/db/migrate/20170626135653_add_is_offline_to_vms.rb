class AddIsOfflineToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_offline, :boolean, default: false
  end
end
