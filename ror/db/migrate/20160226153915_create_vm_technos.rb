class CreateVmTechnos < ActiveRecord::Migration
  def change
    create_table :vm_technos do |t|
      t.references :vm, index: true
      t.references :techno, index: true

      t.timestamps
    end
  end
end
