class AddDockercomposeToFrameworks < ActiveRecord::Migration
  def change
    add_column :frameworks, :dockercompose, :string, limit: 8192
  end
end
