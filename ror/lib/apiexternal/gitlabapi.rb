# External apis use namespace
module Apiexternal
  # Gitlabapi manages request to gitlab api via gitlab gems or rest request
  #
  # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
  class Gitlabapi

    # class attribute, the connector to rest api
    @conn = nil

    # Constructor. init conn attribute
    #
    def initialize
      init_gitlabapi
    end

    # Get private_token
    #
    # @param username [String] the admin username (default is root)
    # @param password [String] the admin password (default is 5iveL!fe)
    # @raise [GitlabApiException] if errors occurs during gitlab request
    def get_private_token(username='root', password='5iveL!fe')
      #json request for session request
      sess_req = {
        login: username,
        password: password
      }

      # Prepare gitlab rest connection
      gitlab_endpoint0 = Rails.application.config.gitlab_endpoint0
      conn_token = Faraday.new(:url => "#{gitlab_endpoint0}", ssl: {verify:false}) do |faraday|
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      response = conn_token.post do |req|
        req.url '/api/v3/session'
        req.headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        req.body = sess_req.to_json
      end

      if response.status != 201
        exception_message = "get private_token failed, error code: #{response.status}"
        raise Exceptions::GitlabApiException.new(exception_message)
      end

      json(response.body)[:private_token]
    end

    # Set ssh key for admin gitlab user from modem unix user
    #
    # @param token [String] private_token
    def init_modemkey_gitlab(token)
      # if sshkey exists for modem, adding it to gitlab user
      if File.exist?('/home/modem/.ssh/id_rsa.pub')
        # Get the value from the file and return it
        add_sshkey = {
          title: 'mvmckey',
          key: File.open('/home/modem/.ssh/id_rsa.pub', 'rb').read.strip
        }

        # Prepare gitlab rest connection
        gitlab_endpoint0 = Rails.application.config.gitlab_endpoint0
        conn_token = Faraday.new(:url => "#{gitlab_endpoint0}", ssl: {verify:false}) do |faraday|
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end

        response = conn_token.post do |req|
          req.url "/api/v3/user/keys"
          req.headers = { 'Content-Type' => 'application/json',
                          'Accept' => 'application/json',
                          'PRIVATE-TOKEN' => token }
          req.body = add_sshkey.to_json
        end
      end
    end

    # Create a new gitlab user
    #
    # @param email [String] the user email
    # @param password [String] the user password
    # @param username [String] the gitlab username
    # @param name [String] the gitlab name
    # @raise [GitlabApiException] if errors occurs
    # @return [Number] the gitlab userid
    def create_user(email, password, username, name)
      gituser = Gitlab.create_user(email, password, username, {name: name, confirm: false})
      return gituser.id
    end

    # Add a new gitlab sshkey
    #
    # @param user_id [Number] the gitlab userid
    # @param name [String] the sshkey name
    # @param key [String] the public key
    # @raise [GitlabApiException] if errors occurs
    # @return [Number] the gitlab sshkeyid
    def add_sshkey(user_id, name, key)

      add_sshkey = {
        title: name,
        key: key
      }

      response = @conn.post do |req|
        req.url "/api/v3/users/#{user_id}/keys"
        req.headers = self.headers
        req.body = add_sshkey.to_json
      end

      if response.status != 201
        exception_message = "add ssh_key #{name} for #{user_id} failed"
        raise Exceptions::GitlabApiException.new(exception_message)
      end

      return json(response.body)[:id]
    end

    # Create a new gitlab project
    #
    # @param name [String] the project name
    # @raise [GitlabApiException] if errors occurs
    # @return [Number] the gitlab projectid
    def create_project(name, gitpath)
      gitlab_project = Gitlab.create_project(
                         gitpath,
                         description: "project #{name}",
                         wall_enabled: true,
                         wiki_enabled: true,
                         issues_enabled: true,
                         snippets_enabled: false,
                         builds_enabled: false,
                         user_id: 1,
                         public: false
                       )

      nextdeployuri = Rails.application.config.nextdeployuri
      Gitlab.add_project_hook(
        gitlab_project.id,
        "https://api.#{nextdeployuri}/api/v1/projects/buildtrigger",
        {
          push_events: true,
          issues_events: false,
          merge_requests_events: false,
          tag_push_events: false,
          enable_ssl_verification: false
        }
      )

      return gitlab_project.id

    rescue => e
      raise Exceptions::GitlabApiException.new("create_project #{gitpath} failed: #{e}")
    end

    # Create branch to a project
    #
    # @param project_id [Number] gitlab project_id
    # @param branch [String] name of the new branch
    # @param ref [String] source of the new branch (sha or other branch name)
    # @raise [GitlabApiException] if errors occurs
    def create_branch(project_id, branch, ref)
      Gitlab.repo_create_branch(project_id, branch, ref)
    rescue => e
        raise Exceptions::GitlabApiException.new("create_branch (#{project_id}, " +
                                                 "#{branch}, #{ref}) failed: #{e}")
    end

    # Protect branch to a project
    #
    # @param project_id [Number] gitlab project_id
    # @param branch [String] name of the branch
    # @raise [GitlabApiException] if errors occurs
    def protect_branch(project_id, branch)
      Gitlab.protect_branch(project_id, branch)
    rescue => e
      raise Exceptions::GitlabApiException.new("protect_branch (#{project_id}, " +
                                               "#{branch}) failed: #{e}")
    end

    # Unprotect branch to a project
    #
    # @param project_id [Number] gitlab project_id
    # @param branch [String] name of the branch
    # @raise [GitlabApiException] if errors occurs
    def unprotect_branch(project_id, branch)
      Gitlab.unprotect_branch(project_id, branch)
    rescue => e
      raise Exceptions::GitlabApiException.new("unprotect_branch (#{project_id}, " +
                                               "#{branch}) failed: #{e}")
    end

    # Update gitlab user
    #
    # @param gitlab_id [Number] the user id
    # @param email [String] the user email
    # @param password [String] the user password
    # @param username [String] the gitlab username
    # @param name [String] the gitlab name
    # @raise [GitlabApiException] if errors occurs
    # @return [Number] the gitlab userid
    def update_user(gitlab_id, email, password, username, name)
      Gitlab.edit_user(gitlab_id, {email: email, password: password, username: username, name: name})
    end

    # Add user to a project team
    #
    # @param project_id [Number] gitlab project id
    # @param user_id [Number] gitlab user id to add
    # @param access_level [Number] access_level (reporter / developer / master)
    # @raise [GitlabApiException] if errors occurs
    def add_user_to_project(project_id, user_id, access_level=30)
      # only one admin, so fix to 40
      access_level = 40 if access_level == 50
      Gitlab.add_team_member(project_id, user_id, access_level)

    rescue => e
      raise Exceptions::GitlabApiException.new("add_user_to_project failed, #{e}")
    end

    # Get list of commits for a project
    #
    # @param id [Number] the project id
    # @param branchname [String] the branch name
    # @raise [GitlabApiException] if errors occurs
    # @return [Array<Hash{Symbol => String}>] commits list
    def get_commits(id, branchname)
      return Gitlab.commits(id, ref_name: branchname)
    rescue => e
      raise Exceptions::GitlabApiException.new("get_commits #{id} failed, #{e}")
    end

    # Get specific commit for a project
    #
    # @param id [Number] the project id
    # @param commithash [String] the commit hash
    # @raise [GitlabApiException] if errors occurs
    # @return [Hash{Symbol => String}] commit details
    def get_commit(id, commithash)
      return Gitlab.commit(id, commithash)
    rescue => e
      raise Exceptions::GitlabApiException.new("get_commit #{commithash} failed, #{e}")
    end

    # Get list of branchs for a project
    #
    # @param id [Number] the project id
    # @raise [GitlabApiException] if errors occurs
    # @return [Array<Hash{Symbol => String}>] Branchs lists
    def get_branches(id)
      return Gitlab.branches(id)
    rescue => e
      raise Exceptions::GitlabApiException.new("get_branchs #{id} failed, #{e}")
    end

    # Get specific branch for a project
    #
    # @param id [Number] the project id
    # @raise [GitlabApiException] if errors occurs
    # @return [Hash{Symbol => String}] Branch details
    def get_branche(id, branchname)
      return Gitlab.branche(id, branchname)
    rescue => e
      raise Exceptions::GitlabApiException.new("get_branch #{id} (#{branchname}) failed, #{e}")
    end

    # Return gitlab projects binding to user_id user
    #
    # @param user_id [Number] the gitlab userid
    # @return [Array<Hash{Symbol => String}>] projects list
    def get_projects(user_id)
      response = @conn.get do |req|
        req.url "/api/v3/projects?sudo=#{user_id}"
        req.headers = self.headers
      end

      if response.status != 200
        exception_message = "get projects for #{user_id} failed"
        raise Exceptions::GitlabApiException.new(exception_message)
      end

      return json(response.body)
    end

    # Return gitlab users binding to gitlab_id project
    #
    # @param gitlab_id [Number] the project id
    # @return [Array<Hash{Symbol => String}>] users list
    def get_project_users(gitlab_id)
      Gitlab.team_members(gitlab_id)
    end

    # Delete a gitlab user
    #
    # @param gitlab_id [Number] the user id
    # @raise [GitlabApiException] if errors occurs
    def delete_user(gitlab_id)
      return if !gitlab_id

      response = @conn.delete do |req|
        req.url "/api/v3/users/#{gitlab_id}"
        req.headers = self.headers
      end

      if response.status != 200
        exception_message = "delete user #{gitlab_id} failed, #{response.body}"
        raise Exceptions::GitlabApiException.new(exception_message)
      end
    end

    # Delete a sshkey
    #
    # @param user_id [Number] the gitlab user id
    # @param gitlab_id [Number] the sshkey id
    # @raise [GitlabApiException] if errors occurs
    def delete_sshkey(user_id, gitlab_id)
      return if !gitlab_id

      response = @conn.delete do |req|
        req.url "/api/v3/users/#{user_id}/keys/#{gitlab_id}"
        req.headers = self.headers
      end

      if response.status != 200
        exception_message = "delete sshkey #{gitlab_id} failed, #{response.body}"
        raise Exceptions::GitlabApiException.new(exception_message)
      end
    end

    # Delete a project
    #
    # @param gitlab_id [Number] the project id
    # @raise [GitlabApiException] if errors occurs
    def delete_project(gitlab_id)
      return if !gitlab_id

      response = @conn.delete do |req|
        req.url "/api/v3/projects/#{gitlab_id}"
        req.headers = self.headers
      end

      if response.status != 200
        exception_message = "delete project #{gitlab_id} failed, #{response.body}"
        raise Exceptions::GitlabApiException.new(exception_message)
      end
    end

    # Delete user to a project team
    #
    # @param project_id [Number] gitlab project id
    # @param user_id [Number] gitlab user id to add
    # @raise [GitlabApiException] if errors occurs
    def delete_user_to_project(project_id, user_id)
      Gitlab.remove_team_member(project_id, user_id)
    rescue => e
      raise Exceptions::GitlabApiException.new("delete_user_to_project failed, #{e}")
    end

    protected

    # Return restful headers
    #
    # @return [Hash{String => String}] http headers hash
    def headers
      { 'Content-Type' => 'application/json',
        'Accept' => 'application/json',
        'PRIVATE-TOKEN' => self.private_token }
    end

    # Return private_token for gitlab admin
    #
    # @return [String] gitlab private token
    def private_token
      # if private_token is setted into rails config, return this value
      return Rails.application.config.gitlab_token unless Rails.application.config.gitlab_token.empty?

      # Test if private_token file exist and create it if needed
      if !File.exists?('tmp/private_token')
        token = get_private_token
        open('tmp/private_token', 'w') { |f| f.puts token }
        init_modemkey_gitlab(token)
      end

      # Get the value from the file and return it
      File.open('tmp/private_token', 'rb').read.strip
    end

    private

    # Init gitlab endpoints
    #
    def init_gitlabapi
      Gitlab.configure do |config|
        config.endpoint = Rails.application.config.gitlab_endpoint
        config.private_token = self.private_token
        config.httparty = { verify: false }
      end

      gitlab_endpoint0 = Rails.application.config.gitlab_endpoint0
      @conn = Faraday.new(:url => "#{gitlab_endpoint0}", ssl: {verify: false}) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    # Helper function to parse json input to hash output
    #
    # @param body [String] json input
    # @return [Hash{Symbol => String}] json content into a hash with symbo indexes
    def json(body)
      JSON.parse(body, symbolize_names: true)
    end

    # Make a sudo for gitlab cmd
    #
    # @param username [String] user to sudo
    def sudo(username)
      Gitlab.sudo = username
    end

    # Disable sudo for gitlab cmd
    #
    def nosudo
      Gitlab.sudo = nil
    end

  end
end
