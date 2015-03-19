class CreateSshkeys < ActiveRecord::Migration
  def change
    create_table :sshkeys do |t|
      t.references :user, index: true
      t.string :key

      t.timestamps
    end
  end
end
