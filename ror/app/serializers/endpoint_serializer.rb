# This class format endpoint properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class EndpointSerializer < ActiveModel::Serializer
  attributes :id, :prefix, :path, :envvars, :aliases, :is_install,
             :ipfilter, :port, :customvhost, :is_sh, :is_import, :is_main, :is_ssl

  has_one :project, key: :project
  has_one :framework, key: :framework

  # Return false for is_install
  #
  # @return [Boolean] false
  def is_install
    false
  end
end
