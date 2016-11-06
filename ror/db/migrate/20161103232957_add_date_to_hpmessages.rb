class AddDateToHpmessages < ActiveRecord::Migration
  def change
    add_column :hpmessages, :date, :string, default: ''
  end
end
