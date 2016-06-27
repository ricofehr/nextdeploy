class AddIsShToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :is_sh, :boolean, default: false
  end
end
