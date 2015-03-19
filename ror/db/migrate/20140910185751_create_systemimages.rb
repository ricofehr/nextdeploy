class CreateSystemimages < ActiveRecord::Migration
  def change
    create_table :systemimages do |t|
      t.string :name
      t.string :glance_id
      t.boolean :enabled

      t.timestamps
    end
  end
end
