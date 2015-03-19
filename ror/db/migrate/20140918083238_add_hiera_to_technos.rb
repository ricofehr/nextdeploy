class AddHieraToTechnos < ActiveRecord::Migration
  def change
    add_column :technos, :hiera, :text
  end
end
