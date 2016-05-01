class AddShortnameToSshkeys < ActiveRecord::Migration
  def change
    add_column :sshkeys, :shortname, :string
  end
end
