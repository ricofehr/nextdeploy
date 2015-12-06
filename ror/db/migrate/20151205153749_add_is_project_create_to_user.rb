class AddIsProjectCreateToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_project_create, :boolean, default: false
  end
end
