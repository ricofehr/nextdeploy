class AddCustomvhostToUris < ActiveRecord::Migration
  def change
    add_column :uris, :customvhost, :string, default: '', limit: 4096
  end
end
