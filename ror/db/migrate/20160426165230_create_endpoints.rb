class CreateEndpoints < ActiveRecord::Migration
  def change
    create_table :endpoints do |t|
      t.references :project, index: true
      t.references :framework, index: true
      t.string :prefix
      t.string :path
      t.string :envvars, limit: 512
      t.string :aliases, limit: 1024
    end
  end
end
