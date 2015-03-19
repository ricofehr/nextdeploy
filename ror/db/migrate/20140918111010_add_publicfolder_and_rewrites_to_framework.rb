class AddPublicfolderAndRewritesToFramework < ActiveRecord::Migration
  def change
    add_column :frameworks, :publicfolder, :string
    add_column :frameworks, :rewrites, :text
  end
end
