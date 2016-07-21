class AddDockercomposeToTechnos < ActiveRecord::Migration
  def change
    add_column :technos, :dockercompose, :string, limit: 8192
  end
end
