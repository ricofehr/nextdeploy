class AddIsSslToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :is_ssl, :boolean, default: false
  end
end
