class AddIsTwitterToHpmessage < ActiveRecord::Migration
  def change
    add_column :hpmessages, :is_twitter, :boolean
  end
end
