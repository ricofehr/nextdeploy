class CreateTechnotypes < ActiveRecord::Migration
  def change
    create_table :technotypes do |t|
      t.string :name

      t.timestamps
    end
  end
end
