# This class format ssh key properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class SshkeySerializer < ActiveModel::Serializer
  attributes :id, :key, :name, :gitlab_id

  has_one :user, key: :user
end
