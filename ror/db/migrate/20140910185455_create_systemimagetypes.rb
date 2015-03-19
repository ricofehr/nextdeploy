class CreateSystemimagetypes < ActiveRecord::Migration
  def change
    create_table :systemimagetypes do |t|
      t.string :name

      t.timestamps
    end
  end
end
