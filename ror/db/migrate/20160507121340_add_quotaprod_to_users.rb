class AddQuotaprodToUsers < ActiveRecord::Migration
  def change
    add_column :users, :quotaprod, :integer, default: 0
  end
end
