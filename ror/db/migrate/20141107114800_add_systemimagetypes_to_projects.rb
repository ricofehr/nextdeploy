class AddSystemimagetypesToProjects < ActiveRecord::Migration
  def change
    add_reference :projects, :systemimagetypes, index: true
  end
end
