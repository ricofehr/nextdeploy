class AddEnabledToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :enabled, :boolean
  end
end
