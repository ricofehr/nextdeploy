# This class format commit properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class CommitSerializer < ActiveModel::Serializer
  attributes :id, :commit_hash, :short_id, :title, :author_name, :author_email, :message, :created_at

  has_one :branche, key: :branche
  has_many :vms, key: :vms
end
