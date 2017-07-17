# This class format ssh key properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class SshkeySerializer < ActiveModel::Serializer
  attributes :id, :key, :name, :gitlab_id

  has_one :user, key: :user

  # HACK return user id (no embed option in AMS 0.10)
  #
  # @return [Number]
  def user
    object.user.id
  end
end
