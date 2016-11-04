class AddIsCorsToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_cors, :boolean
  end
end
