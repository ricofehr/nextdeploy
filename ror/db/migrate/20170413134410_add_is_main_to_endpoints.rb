class AddIsMainToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :is_main, :boolean, default: false
  end
end
