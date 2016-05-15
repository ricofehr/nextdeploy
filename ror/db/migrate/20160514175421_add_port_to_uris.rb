class AddPortToUris < ActiveRecord::Migration
  def change
    add_column :uris, :port, :integer
  end
end
