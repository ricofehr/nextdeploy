class AddStatusToVms < ActiveRecord::Migration
  def change
    add_column :vms, :status, :integer
  end
end
