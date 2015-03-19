class AddGitlabIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :gitlab_id, :integer
  end
end
