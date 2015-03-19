class DropAPIV1Vms < ActiveRecord::Migration
  def up
    drop_table :api_v1_vms
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
