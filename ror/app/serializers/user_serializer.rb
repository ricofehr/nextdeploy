# This class format user properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :authentication_token, :company, :quotavm, :created_at

  has_many :vms, key: :vms
  has_many :projects, key: :projects
  has_many :sshkeys, key: :sshkeys
  has_one :group, key: :group
end
