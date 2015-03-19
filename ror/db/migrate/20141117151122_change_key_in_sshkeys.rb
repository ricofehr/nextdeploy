class ChangeKeyInSshkeys < ActiveRecord::Migration
  def up
    change_column :sshkeys, :key, :text
  end

  def down
    change_column :sshkeys, :key, :string
  end
end
