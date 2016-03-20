class AddCredentialsToVms < ActiveRecord::Migration
  def change
    add_column :vms, :htlogin, :string
    add_column :vms, :htpassword, :string
  end
end
