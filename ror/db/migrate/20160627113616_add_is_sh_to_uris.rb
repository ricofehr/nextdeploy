class AddIsShToUris < ActiveRecord::Migration
  def change
    add_column :uris, :is_sh, :boolean, default: false
  end
end
