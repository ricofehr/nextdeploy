class AddIpfilterToUris < ActiveRecord::Migration
  def change
    add_column :uris, :ipfilter, :string, default: '', limit: 512
  end
end
