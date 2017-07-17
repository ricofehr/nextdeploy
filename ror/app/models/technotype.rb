# Stores details about technology type (Web, Database, ...)
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Technotype < ActiveRecord::Base
  has_many :technos, dependent: :destroy
end
