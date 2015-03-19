class AddGitlabIdToSshkey < ActiveRecord::Migration
  def change
    add_column :sshkeys, :gitlab_id, :integer
  end
end
