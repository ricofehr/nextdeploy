class CreateProjectTechnos < ActiveRecord::Migration
  def change
    create_table :project_technos do |t|
      t.references :project, index: true
      t.references :techno, index: true
      t.text :setting_override

      t.timestamps
    end
  end
end
