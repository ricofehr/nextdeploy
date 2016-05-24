class AddIsBackupToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_backup, :boolean, default: false
  end
end
