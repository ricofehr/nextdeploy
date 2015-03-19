class AddProjectToPrefixDns < ActiveRecord::Migration
  def change
    add_reference :prefix_dns, :project, index: true
  end
end
