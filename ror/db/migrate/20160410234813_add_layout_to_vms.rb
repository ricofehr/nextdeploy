class AddLayoutToVms < ActiveRecord::Migration
  def change
    add_column :vms, :layout, :string, limit: 15
  end
end
