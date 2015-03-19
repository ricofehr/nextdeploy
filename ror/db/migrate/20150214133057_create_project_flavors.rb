class CreateProjectFlavors < ActiveRecord::Migration
  def change
    create_table :project_flavors do |t|
      t.references :project, index: true
      t.references :flavor, index: true
    end
  end
end
