class RemoveSystemimagetypeFromProjects < ActiveRecord::Migration
  def change
    remove_column :projects, :systemimagetype_id
  end
end
