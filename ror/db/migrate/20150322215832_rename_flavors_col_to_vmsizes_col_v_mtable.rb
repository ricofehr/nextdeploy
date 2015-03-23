class RenameFlavorsColToVmsizesColVMtable < ActiveRecord::Migration
  def change
    rename_column :vms, :flavor_id, :vmsize_id
  end
end
