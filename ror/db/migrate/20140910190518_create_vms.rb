class CreateVms < ActiveRecord::Migration
  def change
    create_table :vms do |t|
      t.references :project, index: true
      t.references :user, index: true
      t.references :systemimage, index: true
      t.string :commit
      t.string :nova_id

      t.timestamps
    end
  end
end
