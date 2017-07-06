# Stores all details about a git branch for a project
#
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
class Branche
  # Activemodel object without database table
  include ActiveModel::Serializers::JSON

  attr_reader :id, :name, :project, :commits

  # Constructor
  #
  # @param name [String] name of the branch
  # @param project_id [Integer] id of the project targetting by the branch
  # No return
  def initialize(name, project_id)
    @name = name
    @project_id = project_id
    @id = "#{project_id}-#{name}"
  end

  # Get commits
  #
  # No params
  # @return [Array[Commits]]
  def commits
    Rails.cache.fetch("branches/#{@id}/commits", expires_in: 240.hours) do
      Commit.all(@id)
    end
  end

  # Find function. Return a branch object from his id
  #
  # @param id [String] projectid-branchname string
  # @return [Branche]
  def self.find(id)
    @id = id
    tab = id.split('-')
    project_id = tab.shift
    branchname = tab.join('-')

    new(branchname, project_id)
  end

  # Return all branchs for a project
  #
  # @param project_id [Integer] id of the project
  # @return [Array[Branche]]
  def self.all(project_id)
    # get project from project_id
    gitlab_id = Rails.cache.fetch("projects/#{project_id}/gitlab_id", expires_in: 240.hours) do
      Project.find(project_id).gitlab_id
    end

    begin
      # Init gitlab external api
      gitlabapi = Apiexternal::Gitlabapi.new
      branches = gitlabapi.get_branches(gitlab_id)
    rescue Exceptions::NextDeployException => me
      me.log
    end

    branches.map! {|branch| new(branch.name, project_id)}
  end

  # Return the project associated with the branch
  #
  # @return [Project]
  def project
    Rails.cache.fetch("branches/#{@id}/project", expires_in: 240.hours) do
      Project.find(@project_id)
    end
  end

  private
end
