class AddPuppetclassToFrameworks < ActiveRecord::Migration
  def change
    add_column :frameworks, :puppetclass, :string
  end
end
