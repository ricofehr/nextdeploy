class AddIsHtToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :is_ht, :boolean, default: false
  end
end
