class AddUserRefToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :owner, references: :users, index: true, foreign_key: true
  end
end
