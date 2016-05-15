class RemoveFrameworkFromProject < ActiveRecord::Migration
  def change
    remove_column :projects, :framework_id, :string
  end
end
