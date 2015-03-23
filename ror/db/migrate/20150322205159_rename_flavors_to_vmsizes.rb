class RenameFlavorsToVmsizes < ActiveRecord::Migration
  def change
    rename_table :flavors, :vmsizes
    rename_table :project_flavors, :project_vmsizes
  end
end
