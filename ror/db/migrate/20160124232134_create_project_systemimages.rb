class CreateProjectSystemimages < ActiveRecord::Migration
  def change
    create_table :project_systemimages do |t|
      t.references :project, index: true
      t.references :systemimage, index: true
    end
  end
end
