class AddIsSslToUris < ActiveRecord::Migration
  def change
    add_column :uris, :is_ssl, :boolean, default: false
  end
end
