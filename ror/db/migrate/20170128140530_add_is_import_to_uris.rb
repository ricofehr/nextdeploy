class AddIsImportToUris < ActiveRecord::Migration
  def change
    add_column :uris, :is_import, :boolean, default: true
  end
end
