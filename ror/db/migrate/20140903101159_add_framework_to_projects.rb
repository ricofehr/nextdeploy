class AddFrameworkToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :framework, index: true
  end
end
