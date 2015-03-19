class AddBrandToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :brand, index: true
  end
end
