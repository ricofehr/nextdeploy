class CreateUserProjects < ActiveRecord::Migration
  def change
    create_table :user_projects do |t|
      t.references :user, index: true
      t.references :project, index: true

      t.timestamps
    end
  end
end
