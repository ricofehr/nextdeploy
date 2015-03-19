class CreatePrefixDns < ActiveRecord::Migration
  def change
    create_table :prefix_dns do |t|
      t.string :URI

      t.timestamps
    end
  end
end
