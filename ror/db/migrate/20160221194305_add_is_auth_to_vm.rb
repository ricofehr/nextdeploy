class AddIsAuthToVm < ActiveRecord::Migration
  def change
    add_column :vms, :is_auth, :boolean, default: true
  end
end
