class Fixcommit < ActiveRecord::Migration
  def self.up
    rename_column :vms, :commit, :commit_id
  end

  def self.down
    rename_column :vms, :commit_id, :commit
  end
end
