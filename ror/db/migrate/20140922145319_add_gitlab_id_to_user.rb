class AddGitlabIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :gitlab_id, :integer
  end
end
