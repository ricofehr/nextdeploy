class AddQuotavmToUser < ActiveRecord::Migration
  def change
    add_column :users, :quotavm, :integer
  end
end
