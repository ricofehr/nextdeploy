class RemoveIsassetsFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :isassets, :boolean
  end
end
