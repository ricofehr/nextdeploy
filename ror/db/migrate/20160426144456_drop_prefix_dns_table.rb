class DropPrefixDnsTable < ActiveRecord::Migration
  def change
    drop_table :prefix_dns
  end
end
