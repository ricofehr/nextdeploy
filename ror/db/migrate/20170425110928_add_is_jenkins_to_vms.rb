class AddIsJenkinsToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_jenkins, :boolean, default: false
  end
end
