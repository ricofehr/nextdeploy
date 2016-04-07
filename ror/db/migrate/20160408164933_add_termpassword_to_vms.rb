class AddTermpasswordToVms < ActiveRecord::Migration
  def change
    add_column :vms, :termpassword, :string
  end
end
