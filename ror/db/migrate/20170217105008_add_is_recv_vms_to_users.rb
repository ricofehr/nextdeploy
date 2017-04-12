class AddIsRecvVmsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_recv_vms, :boolean, default: false
  end
end
