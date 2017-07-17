# This class format endpoint properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class UriSerializer < ActiveModel::Serializer
  attributes :id, :absolute, :path, :envvars, :aliases,
             :ipfilter, :port, :customvhost, :is_sh,
             :is_import, :is_redir_alias, :is_main, :is_ssl

  has_one :vm, key: :vm
  has_one :framework, key: :framework

  # HACK return vm id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def vm
    object.vm.id
  end

  # HACK return framework id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def framework
    object.framework.id
  end
end
