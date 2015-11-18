module Apiexternal
  # Gitlabapi manages request to gitlab api via gitlab gems or rest request
  #
  # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
  class Gitlabapi

    # class attribute, the connector to rest api
    @conn = nil

    # Constructor. init conn attribute
    #
    # No param
    # No return
    def initialize
      init_gitlabapi
    end

    # Get private_token
    #
    # @param username [String] the admin username (default is root)
    # @param password [String] the admin password (default is 5iveL!fe)
    # @raise Exceptions::GitlabApiException if errors occurs
    # No return
    def get_private_token(username='root', password='5iveL!fe')

      #json request for session request
      sess_req = {
        login: username,
        password: password
      }

      # Prepare gitlab rest connection
      conn_token = Faraday.new(:url => "#{Rails.application.config.gitlab_endpoint0}", ssl: {verify:false}) do |faraday|
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      response = conn_token.post do |req|
        req.url '/api/v3/session'
        req.headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        req.body = sess_req.to_json
      end

      raise Exceptions::GitlabApiException.new("get private_token failed, error code: #{response.status}") if response.status != 201

      #return private_token value
      json(response.body)[:private_token]
    end

    # Set ssh key for admin gitlab user from modem unix user
    #
    # @param token [String] private_token
    # No return
    def init_modemkey_gitlab(token)
      # if sshkey exists for modem, adding it to gitlab user
      if File.exist?('/home/modem/.ssh/id_rsa.pub')
        # Get the value from the file and return it
        add_sshkey = {
          title: 'mvmckey',
          key: File.open('/home/modem/.ssh/id_rsa.pub', 'rb').read.strip
        }

        # Prepare gitlab rest connection
        conn_token = Faraday.new(:url => "#{Rails.application.config.gitlab_endpoint0}", ssl: {verify:false}) do |faraday|
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        end

        response = conn_token.post do |req|
          req.url "/api/v3/user/keys"
          req.headers = { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'PRIVATE-TOKEN' => token }
          req.body = add_sshkey.to_json
        end
      end
    end

    # Create a new gitlab user
    #
    # @param email [String] the user email
    # @param password [String] the user password
    # @param username [String] the gitlab username
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Integer] the gitlab userid
    def create_user(email, password, username)
      #begin
        gituser = Gitlab.create_user(email, password, {username: username})
      #rescue Exceptions => e
      #  raise Exceptions::GitlabApiException.new("create user #{email} failed, #{e}")
      #end

      return gituser.id
    end

    # Add a new gitlab sshkey
    #
    # @param username [String] the gitlab username
    # @param name [String] the sshkey name
    # @param key [String] the public key
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Integer] the gitlab sshkeyid
    def add_sshkey(username, name, key)
      sudo(username)
      begin
        gitlab_id = Gitlab.create_ssh_key(name, key).id
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("add ssh_key #{name} for #{username} failed, #{e}")
      end
      nosudo

      return gitlab_id
    end

    # Create a new gitlab project
    #
    # @param name [String] the project name
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Integer] the gitlab projectid
    def create_project(name, gitpath)
      begin
         gitlab_project = Gitlab.create_project(gitpath, description: "project #{name}",
                                                        wall_enabled: true,
                                                        wiki_enabled: true,
                                                        issues_enabled: true,
                                                        user_id: 1,
                                                        public: false)

      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("create_project #{gitpath} failed: #{e}")
      end

      return gitlab_project.id
    end

    # Create branch to a project
    #
    # @param project_id [integer] gitlab project_id
    # @param branch [String] name of the new branch
    # @param ref [String] source of the new branch (sha or other branch name)
    # @raise Exceptions:r:GitlabApiException if errors occurs
    # @return nothing
    def create_branch(project_id, branch, ref)
      begin
        Gitlab.repo_create_branch(project_id, branch, ref)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("create_branch (#{project_id}, #{branch}) failed: #{e}")
      end
    end

    # Protect branch to a project
    #
    # @param project_id [integer] gitlab project_id
    # @param branch [String] name of the branch
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return nothing
    def protect_branch(project_id, branch)
      begin
        Gitlab.protect_branch(project_id, branch)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("protect_branch (#{project_id}, #{branch}) failed: #{e}")
      end
    end

    # Unprotect branch to a project
    #
    # @param project_id [integer] gitlab project_id
    # @param branch [String] name of the branch
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return nothing
    def unprotect_branch(project_id, branch)
      begin
        Gitlab.unprotect_branch(project_id, branch)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("unprotect_branch (#{project_id}, #{branch}) failed: #{e}")
      end
    end

    # Update gitlab user
    #
    # @param gitlab_id [Integer] the user id
    # @param email [String] the user email
    # @param password [String] the user password
    # @param username [String] the gitlab username
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Integer] the gitlab userid
    def update_user(gitlab_id, email, password, username)
      #begin
        gituser = Gitlab.edit_user(gitlab_id, {email: email, password: password, username: username})
      #rescue Exceptions => e
      # raise Exceptions::GitlabApiException.new("create user #{email} failed, #{e}")
      #end
    end

    # Add user to a project team
    #
    # @param project_id [integer] gitlab project id
    # @param user_id [integer] gitlab user id to add
    # @param access_level [integer] access_level (reporter / developer / master)
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return nothing
    def add_user_to_project(project_id, user_id, access_level=30)

      # only one admin, so fix to 40
      access_level = 40 if access_level == 50

      begin
        Gitlab.add_team_member(project_id, user_id, access_level)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("add_user_to_project failed, #{e}")
      end
    end

    # Get list of commits for a project
    #
    # @param id [integer] the project id
    # @param branchname [String] the branch name
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Array] commits list
    def get_commits(id, branchname)
      begin
        commits = Gitlab.commits(id, ref_name: branchname)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("get_commits #{id} failed, #{e}")
      end

      return commits
    end

    # Get specific commit for a project
    #
    # @param id [integer] the project id
    # @param commithash [String] the commit hash
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Hash] commit details
    def get_commit(id, commithash)
      begin
        commit = Gitlab.commit(id, commithash)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("get_commit #{commithash} failed, #{e}")
      end

      return commit
    end

    # Get list of branchs for a project
    #
    # @param id [integer] the project id
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Array] Branchs lists
    def get_branches(id)
      begin
        branchs = Gitlab.branches(id)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("get_branchs #{id} failed, #{e}")
      end

      return branchs
    end

    # Get specific branch for a project
    #
    # @param id [integer] the project id
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return [Hash] Branch details
    def get_branche(id, branchname)
      begin
        branch = Gitlab.branche(id, branchname)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("get_branch #{id} (#{branchname}) failed, #{e}")
      end

      return branch
    end

    # Return gitlab projects binding to username user
    #
    # @param username [String] the gitlab username
    # @returns [Array] projects list
    def get_projects(username)
      sudo(username)
      projects = Gitlab.projects
      nosudo

      projects
    end

    # Return gitlab users binding to gitlab_id project
    #
    # @param gitlab_id [Integer] the project id
    # @returns [Array] users list
    def get_project_users(gitlab_id)
      Gitlab.team_members(gitlab_id)
    end

    # Delete a gitlab user
    #
    # @param gitlab_id [Integer] the user id
    # @raise Exceptions::GitlabApiException if errors occurs
    # No return
    def delete_user(gitlab_id)
      return if !gitlab_id

      response = @conn.delete do |req|
        req.url "/api/v3/users/#{gitlab_id}"
        req.headers = self.headers
      end

      raise Exceptions::GitlabApiException.new("delete user #{gitlab_id} failed, #{response.body}") if response.status != 200
    end

    # Delete a sshkey
    #
    # @param username [String] the gitlab username
    # @param gitlab_id [Integer] the sshkey id
    # @raise Exceptions::GitlabApiException if errors occurs
    # No return
    def delete_sshkey(username, gitlab_id)
      sudo(username)
      begin
        Gitlab.delete_ssh_key(gitlab_id)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("delete ssh_key #{gitlab_id} failed, #{e}")
      end
      nosudo
    end

    # Delete a project
    #
    # @param gitlab_id [Integer] the project id
    # @raise Exceptions::GitlabApiException if errors occurs
    # No return
    def delete_project(gitlab_id)
      return if !gitlab_id

      response = @conn.delete do |req|
        req.url "/api/v3/projects/#{gitlab_id}"
        req.headers = self.headers
      end

      raise Exceptions::GitlabApiException.new("delete project #{gitlab_id} failed, #{response.body}") if response.status != 200

      #begin
      #  Gitlab.delete_project(gitlab_id)
      #rescue Exceptions => e
      #  Exceptions::GitlabApiException.new("delete project #{gitlab_id} failed, #{e}")
      #end
    end

    # Delete user to a project team
    #
    # @param project_id [integer] gitlab project id
    # @param user_id [integer] gitlab user id to add
    # @raise Exceptions::GitlabApiException if errors occurs
    # @return nothing
    def delete_user_to_project(project_id, user_id)

      begin
        Gitlab.remove_team_member(project_id, user_id)
      rescue Exceptions => e
        raise Exceptions::GitlabApiException.new("delete_user_to_project failed, #{e}")
      end
    end

    protected

    # Return restful headers
    #
    # No params
    # @return [Hash] http headers hash
    def headers
      { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'PRIVATE-TOKEN' => self.private_token }
    end

    # Return private_token for gitlab admin
    #
    # No params
    # @return [String] gitlab private token
    def private_token
      # if private_token is setted into rails config, return this value
      return Rails.application.config.gitlab_token unless Rails.application.config.gitlab_token.empty?

      # Test if private_token file exist and create it if needed
      if ! File.exists?('tmp/private_token')
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
    # No params
    # No return
    def init_gitlabapi
      Gitlab.configure do |config|
        config.endpoint       = Rails.application.config.gitlab_endpoint
        config.private_token = self.private_token
        config.httparty = { verify: false }
      end

      @conn = Faraday.new(:url => "#{Rails.application.config.gitlab_endpoint0}", ssl: {verify: false}) do |faraday|
        faraday.adapter  Faraday.default_adapter #:net_http_persistent  # make requests with persistent adapter
      end
    end

    # Helper function to parse json input to hash output
    #
    # @param body [String] json input
    # @return [Hash] json content into a hash with symbo indexes
    def json(body)
      JSON.parse(body, symbolize_names: true)
    end

    # Make a sudo for gitlab cmd
    #
    # @param username [String] user to sudo
    # No return
    def sudo(username)
      Gitlab.sudo = username
    end

    # Disable sudo for gitlab cmd
    #
    # No param
    # No return
    def nosudo
      Gitlab.sudo = nil
    end

  end
end
