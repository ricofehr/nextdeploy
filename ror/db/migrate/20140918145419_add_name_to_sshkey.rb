class AddNameToSshkey < ActiveRecord::Migration
  def change
    add_column :sshkeys, :name, :string
  end
end
