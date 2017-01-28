class AddIsImportToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :is_import, :boolean, default: true
  end
end
