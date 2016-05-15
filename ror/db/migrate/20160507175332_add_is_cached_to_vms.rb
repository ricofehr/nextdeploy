class AddIsCachedToVms < ActiveRecord::Migration
  def change
    add_column :vms, :is_cached, :boolean, default: false
  end
end
