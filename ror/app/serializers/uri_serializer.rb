# This class format endpoint properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class UriSerializer < ActiveModel::Serializer
  attributes :id, :absolute, :path, :envvars, :aliases,
             :ipfilter, :port, :customvhost, :is_sh,
             :is_import, :is_redir_alias, :is_main

  # ensure no point char in absolute and aliases
  def attributes
    data = super
    data[:absolute] = data[:absolute].gsub('\.','-').gsub("#{Rails.application.config.os_suffix}.gsub('\.','-')","#{Rails.application.config.os_suffix}")
    data[:aliases] = data[:aliases].gsub('\.','-').gsub("#{Rails.application.config.os_suffix}.gsub('\.','-')","#{Rails.application.config.os_suffix}")
    data
  end

  has_one :vm, key: :vm
  has_one :framework, key: :framework
end
