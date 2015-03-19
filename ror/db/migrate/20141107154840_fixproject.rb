class Fixproject < ActiveRecord::Migration
  def self.up
    rename_column :projects, :systemimagetypes_id, :systemimagetype_id
  end

  def self.down
    rename_column :projects, :systemimagetype_id, :systemimagetypes_id
  end
end
