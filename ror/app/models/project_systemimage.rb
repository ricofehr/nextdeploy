# Just a Joint class between Project and Systemimage objects
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class ProjectSystemimage < ActiveRecord::Base
  belongs_to :project
  belongs_to :systemimage
end
