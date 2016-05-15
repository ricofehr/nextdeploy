class AddPortToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :port, :integer
  end
end
