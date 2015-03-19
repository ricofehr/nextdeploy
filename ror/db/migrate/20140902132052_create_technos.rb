class CreateTechnos < ActiveRecord::Migration
  def change
    create_table :technos do |t|
      t.string :name
      t.string :puppetclass

      t.timestamps
    end
  end
end
