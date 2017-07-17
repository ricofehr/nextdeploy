# This class format hpmessage properties for json output
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class HpmessageSerializer < ActiveModel::Serializer
  attributes :id, :title, :message, :ordering, :is_twitter, :date
end
