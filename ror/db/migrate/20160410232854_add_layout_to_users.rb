class AddLayoutToUsers < ActiveRecord::Migration
  def change
    add_column :users, :layout, :string, limit: 15
  end
end
