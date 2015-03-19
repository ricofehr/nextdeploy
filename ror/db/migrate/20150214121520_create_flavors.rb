class CreateFlavors < ActiveRecord::Migration
  def change
    create_table :flavors do |t|
      t.string :title
      t.text :description
    end
  end
end
