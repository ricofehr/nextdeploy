class AddSystemimagetypeToSystemimage < ActiveRecord::Migration
  def change
    add_reference :systemimages, :systemimagetype, index: true
  end
end
