# This class format endpoint properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class EndpointSerializer < ActiveModel::Serializer
  attributes :id, :prefix, :path, :envvars, :aliases, :is_install, :ipfilter, :port, :customvhost

  has_one :project, key: :project
  has_one :framework, key: :framework

  def is_install
    false
  end
end
