class AddNameToVm < ActiveRecord::Migration
  def change
    add_column :vms, :name, :string
  end
end
