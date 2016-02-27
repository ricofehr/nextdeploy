class AddTechnotypeRefToTechnos < ActiveRecord::Migration
  def change
    add_reference :technos, :technotype, index: true
  end
end
