class AddPlaybookToTechnos < ActiveRecord::Migration
  def change
    add_column :technos, :playbook, :string, limit: 8192
  end
end
