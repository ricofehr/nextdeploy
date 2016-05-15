class AddIpfilterToEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :ipfilter, :string, default: '', limit: 512
  end
end
