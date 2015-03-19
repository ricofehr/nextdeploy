class CreateProjects < ActiveRecord::Migration
  def change
    drop_table :projects
    create_table :projects do |t|
      t.string :name
      t.string :gitpath
      t.boolean :isassets

      t.timestamps
    end
  end
end
