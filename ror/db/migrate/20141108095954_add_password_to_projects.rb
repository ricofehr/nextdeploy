class AddPasswordToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :password, :string
  end
end
