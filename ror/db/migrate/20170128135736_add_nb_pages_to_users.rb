class AddNbPagesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :nbpages, :integer, default: 11
  end
end
