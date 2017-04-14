class AddIsMainToUris < ActiveRecord::Migration
  def change
    add_column :uris, :is_main, :boolean, default: false
  end
end
