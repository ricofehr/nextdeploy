class CreateHpmessages < ActiveRecord::Migration
  def change
    create_table :hpmessages do |t|
      t.string :title
      t.text :message
      t.integer :access_level_min
      t.integer :access_level_max
      t.integer :expiration
      t.integer :ordering
    end
  end
end
