# Endpoint class who joints framework and project with some extra field
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Endpoint < ActiveRecord::Base
  # IO function are included into helpers module
  include EndpointsHelper

  belongs_to :project
  belongs_to :framework
end
