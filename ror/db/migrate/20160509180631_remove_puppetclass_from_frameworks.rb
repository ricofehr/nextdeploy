class RemovePuppetclassFromFrameworks < ActiveRecord::Migration
  def change
    remove_column :frameworks, :puppetclass, :string
  end
end
