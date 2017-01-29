class AddIsRedirAliasToUris < ActiveRecord::Migration
  def change
    add_column :uris, :is_redir_alias, :boolean, default: false
  end
end
