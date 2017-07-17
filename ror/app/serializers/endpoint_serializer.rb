# This class format endpoint properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class EndpointSerializer < ActiveModel::Serializer
  attributes :id, :prefix, :path, :envvars, :aliases, :is_install,
             :ipfilter, :port, :customvhost, :is_sh, :is_import, :is_main, :is_ssl

  has_one :project, key: :project
  has_one :framework, key: :framework

  # HACK return project id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def project
    object.project.id
  end

  # HACK return framework id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def framework
    object.framework.id
  end

  # Return false for is_install
  #
  # @return [Boolean] false
  def is_install
    false
  end
end
