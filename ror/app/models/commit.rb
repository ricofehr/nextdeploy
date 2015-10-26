# This object stores all property about a git commit
#
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
class Commit
  # Activemodel object without database table
  include ActiveModel::Serializers::JSON

  # get on attributes
  attr_reader :id, :commit_hash, :project_id, :branche_id, :short_id, :title, :author_name, :author_email, :message, :created_at

  # gitlab api connector
  @gitlabapi = nil

  # Constructor
  #
  # @param commit_hash [String] hash id of the commit
  # @param branche_id [String] projectid-branchname id of the branch where the commit is coming from
  # @param options [Array[String]] optional parameters associated with a commit: author, date, message, ...
  def initialize(commit_hash, branche_id, options={})
    @id = "#{branche_id}-#{commit_hash}"
    @commit_hash = commit_hash
    @branche_id = branche_id
    @project_id = branche_id.split('-')[0]

    if options.empty?
      project = Project.find(@project_id)

      begin
        commit = 
          # cache commit object during 1 day   
          Rails.cache.fetch("commits/#{@id}", expires_in: 24.hours) do
            @gitlabapi = Apiexternal::Gitlabapi.new
            @gitlabapi.get_commit(project.gitlab_id, commit_hash)          
          end

        options[:short_id] = commit.short_id
        options[:title] = commit.title
        options[:author_name] = commit.author_name
        options[:author_email] = commit.author_email
        options[:message] = commit.message
        options[:created_at] = commit.created_at
      rescue Exceptions::MvmcException => me
        me.log
      end
    end

    @short_id = options[:short_id]
    @title = options[:title]
    @author_name = options[:author_name]
    @author_email = options[:author_email]
    @message = options[:message]
    @created_at = options[:created_at]
  end

  # Find function. Return a commit object from his id
  #
  # @param id [String] projectid-branchname-commithash string
  # @return [Commit]
  def self.find(id)
    @id = id
    tab = id.split('-')
    commit_hash = tab.pop
    branche_id = tab.join('-')
    
    new(commit_hash, branche_id)          
  end

  # Return all commits for a branch
  #
  # @param branche_id [String] id of the branch
  # @return [Array[Commit]]
  def self.all(branche_id)
    @gitlabapi = Apiexternal::Gitlabapi.new

    tab = branche_id.split('-')
    project_id = tab.shift
    branchname = tab.join('-')

    project = Project.find(project_id)

    begin
      commits = @gitlabapi.get_commits(project.gitlab_id, branchname)
    rescue Exceptions::MvmcException => me
      me.log
    end

    commits.map! {|commit| new(commit.id, branche_id, {shortid: commit.short_id, title: commit.title,
                                                                author_name: commit.author_name, author_email: commit.author_email,
                                                                message: commit.message, created_at: commit.created_at}) }
  end

  # Return the branch associated with the commit
  #
  # @return [Branche]
  def branche
    Branche.find(@branche_id)
  end

  # Return the vms associated with the commit
  #
  # @return [Array[Vm]]
  def vms
    Vm.where(commit_id: @id)
  end

end
