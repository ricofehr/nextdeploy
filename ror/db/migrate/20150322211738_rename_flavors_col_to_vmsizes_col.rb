class RenameFlavorsColToVmsizesCol < ActiveRecord::Migration
  def change
    rename_column :project_vmsizes, :flavor_id, :vmsize_id
  end
end
