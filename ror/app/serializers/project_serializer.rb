# This class format project properties for json output
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :gitpath, :enabled, :login, :password, :created_at
  delegate :current_user, to: :scope

  has_many :users, key: :users
  has_many :technos, key: :technos
  has_many :vmsizes, key: :vmsizes
  has_many :branches, key: :branches
  has_one :brand, key: :brand
  has_one :framework, key: :framework
  has_one :systemimagetype, key: :systemimagetype

  # avoid for no lead/admin users to see other users details
  def users
    if current_user.admin?
      users_a = object.users.select { |u| u.id != current_user.id }
      users_a.unshift(current_user)
    elsif current_user.lead?
      users_a = object.users.select { |u| ! u.admin? && u.id != current_user.id }
      users_a.unshift(current_user)
    else
      [] << current_user
    end
  end

  # gitpath needs string changes
  def attributes
    data = super
    data[:gitpath] = Rails.application.config.gitlab_endpoint0.gsub(/https?:\/\//, '') << ':/root/' << data[:gitpath] if current_user.lead?
    data
  end
end
