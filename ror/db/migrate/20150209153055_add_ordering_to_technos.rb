class AddOrderingToTechnos < ActiveRecord::Migration
  def change
    add_column :technos, :ordering, :integer
  end
end
