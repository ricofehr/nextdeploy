class Altervmschangeflavorcolumn < ActiveRecord::Migration
  def change
    remove_column :vms, :flavor, :string
    add_column :vms, :flavor_id, :integer
  end
end
