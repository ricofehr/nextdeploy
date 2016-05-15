class CreateUris < ActiveRecord::Migration
  def change
    create_table :uris do |t|
      t.references :vm, index: true
      t.references :framework, index: true
      t.string :absolute, limit: 512
      t.string :path
      t.string :envvars, limit: 512
      t.string :aliases, limit: 2048
    end
  end
end
