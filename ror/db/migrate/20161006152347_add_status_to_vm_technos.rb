class AddStatusToVmTechnos < ActiveRecord::Migration
  def change
    add_column :vm_technos, :status, :boolean, default: true
  end
end
