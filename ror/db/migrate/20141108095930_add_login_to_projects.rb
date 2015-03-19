class AddLoginToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :login, :string
  end
end
