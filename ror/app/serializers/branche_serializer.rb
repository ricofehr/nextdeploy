# This class format branche properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class BrancheSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :commits, key: :commits
  has_one :project, key: :project
end
