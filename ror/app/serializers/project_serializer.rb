# This class format project properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :gitpath, :isassets, :enabled, :login, :password, :created_at

  # gitpath needs post string actions
  def attributes
    data = super
    data[:gitpath] = Rails.application.config.gitlab_endpoint0.gsub('http://', '') << '/root/' << data[:gitpath]
    data
  end


  has_many :users, key: :users
  has_many :technos, key: :technos
  has_many :flavors, key: :flavors
  has_many :branches, key: :branches
  has_one :brand, key: :brand
  has_one :framework, key: :framework
  has_one :systemimagetype, key: :systemimagetype
end
