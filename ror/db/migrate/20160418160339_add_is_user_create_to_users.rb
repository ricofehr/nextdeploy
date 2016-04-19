class AddIsUserCreateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_user_create, :boolean, default: false
  end
end
