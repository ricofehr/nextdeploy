class AddTopicToVms < ActiveRecord::Migration
  def change
    add_column :vms, :topic, :string
  end
end
