# Stores all details about a git branch for a project
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Branche
  # Activemodel object without database table
  include ActiveModel::Serializers::JSON

  attr_reader :id, :name, :project, :commits


  # gitlab api connector
  @gitlabapi = nil

  # Constructor
  #
  # @param name [String] name of the branch
  # @param project_id [Integer] id of the project targetting by the branch
  # No return
  def initialize(name, project_id)
    @name = name
    @project_id = project_id
    @id = "#{project_id}-#{name}"

    # cache commits array during 10min
    @commits = Commit.all(@id)    
      Rails.cache.fetch("branches/#{@id}/commits", expires_in: 1.minute) do
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
    # Init gitlab external api
    @gitlabapi = Apiexternal::Gitlabapi.new

    # get project from project_id
    project = Project.find(project_id)

    begin
      branches = @gitlabapi.get_branches(project.gitlab_id)
    rescue Exceptions::MvmcException => me
      me.log
    end

    branches.map! {|branch| new(branch.name, project_id)}
  end

  # Return the project associated with the branch
  #
  # @return [Project]
  def project
     Project.find(@project_id)
  end

  private
end
