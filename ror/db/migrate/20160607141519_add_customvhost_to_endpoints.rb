class AddCustomvhostToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :customvhost, :string, default: '', limit: 4096
  end
end
