#!/usr/bin/env ruby

require 'thor'
require 'faraday'
require 'active_support'
require 'active_support/core_ext'
require 'uri'

class Mvmc < Thor
  # desc "mvmc h", "display help"
  # def h
  # puts <<-LONGDESC
  #   This client communicates with mvmc remote services. It needs a configuration files "mvmc.conf" in current path or in /etc/mvmc.conf.
  #   This file must include 2 lines with mvmc credentials like this:
  #   email: user@mvmc-openstack.local
  #   password: wordpass
  #
  #   `mvmc help` will print help about this command
  #   `mvmc up` launch current commit into vm
  #   `mvmc destroy` destroy current vm associated to this project
  #   `mvmc ssh` ssh into current vm
  #   `mvmc projects` list projects
  #
  #   > $ mvmc up
  # LONGDESC
  # end

  # Launch current commit into a new vms on mvmc cloud
  #
  desc "up", "launch current commit to remote mvmc"
  def up
    init

    if ! @project
      warn("Git repository for #{gitpath} not found, have-you already import this project ?")
      exit
    end

    launch_req = { vm: { project_id: @project[:id], flavor_id: 1, user_id: @user[:id], systemimage_id: 1, commit_id: commitid } }
    
    response = @conn.post do |req|
      req.url "/api/v1/vms"
      req.headers = rest_headers
      req.body = launch_req.to_json
    end

    json(response.body)[:vm]
  end

  # Destroy current vm
  #
  desc "destroy", "destroy current vm"
  def destroy
    init

    if ! @vm
      warn("No vm for commit #{commitid}")
      exit
    end

    response = @conn.delete do |req|
      req.url "/api/v1/vms/#{@vm[:id]}"
      req.headers = rest_headers
    end
  end

  # List current active vms
  #
  desc "list", "list launched vms for current user"
  def list
    init

    if @vms.empty?
      puts "No vms for #{@user[:email]}"
      return
    end

    @vms.each do |vm|
      project = @projects.select { |project| project[:id] == vm[:project] }

      puts "Project #{project[0][:name]}, Commit #{vm[:commit]}"
    end
  end

  # List projects for current user
  #
  desc "projects", "list projects for current user"
  def projects
    init

    if @projects.empty?
      puts "No projects for #{@user[:email]}"
      return
    end

    @projects.sort_by! { |project| project[:name] }
    @projects.each { |project| puts "Project #{project[:name]}: git clone git@#{project[:gitpath]}" }
  end

  # Ssh into remote vm
  #
  desc "ssh", "ssh into remote vm"
  def ssh
    init

    if ! @vm
      warn("No vm for commit #{commitid}")
      exit
    end
    
    %x{ssh modem@#{@vm[:floating_ip]}}
  end


  no_commands do
    
    # Init datas
    #
    def init
      init_properties
      init_conn
      token
      init_brands
      init_frameworks
      get_project
      get_vm
    end

    # Retrieve settings parameters
    #
    def init_properties
      fp = nil
      @email = nil
      @password = nil
      @endpoint = nil

      # Open setting file
      if File.exists?('mvmc.conf')
        fp = File.open('mvmc.conf', 'r')
      else
        if ! File.exists?('/etc/mvmc.conf')
          error('no mvmc.conf or /etc/mvmc.conf')
        end
        fp = File.open('/etc/mvmc.conf', 'r')
      end

      # Get properties
      while (line = fp.gets)
        if (line.match(/^email:.*$/))
          @email = line.gsub('email:', '').squish
        end

        if (line.match(/^password:.*$/))
          @password = line.gsub('password:', '').squish
        end

        if (line.match(/^endpoint:.*$/))
          @endpoint = line.gsub('endpoint:', '').squish
        end
      end
      fp.close

      error("no email into mvmc.conf") if @email == nil
      error("no password into mvmc.conf") if @password == nil
      error("no endpoint into mvmc.conf") if @endpoint == nil
    end

    # Get current git url
    #
    # No params
    # @return [String] the git path
    def gitpath
      %x{git config --get remote.origin.url | sed "s;^.*root/;;" | sed "s;\.git$;;"}.squish
    end

    # Get current commit
    #
    # No param
    # @return [String] a commit hash
    def currentcommit
      %x{git rev-parse HEAD}.squish
    end

    # Get current branch
    #
    # No params
    # @return [String] a branch name
    def currentbranch
      %x{git branch | grep "*" | sed "s;* ;;"}.squish
    end

    # Get unique id (for the model of mvmc) for current commit
    #
    # No params
    # @return [String] id of the commit
    def commitid
      "#{@project[:id]}-#{currentbranch}-#{currentcommit}"
    end

    # Get current project follow the gitpath value
    #
    # No params
    # @return [Array[String]] json output for a project
    def get_project
      gitp = gitpath
      
      response = @conn.get do |req|
        req.url "/api/v1/projects/git/#{gitp}"
        req.headers = rest_headers
      end

      if response.body == "null"
        @project = {}
        return
      end

      @project = json(response.body)[:project]
    end

    # get he vm for current commit 
    #
    # No params
    # @return [Array[String]] json output for a vm
    def get_vm
      commit = commitid

      response = @conn.get do |req|
        req.url "/api/v1/vms/user/#{@user[:id]}/#{commit}"
        req.headers = rest_headers
      end

      if response.body == "null"
        @vm = {}
        return
      end

      @vm = json(response.body)[:vms][0]
    end

    # Init rest connection
    #
    def init_conn
      @conn = Faraday.new(:url => "http://#{@endpoint}") do |faraday|
        faraday.adapter  Faraday.default_adapter
        faraday.port = 80
      end
    end

    # Authenticate user
    #
    # @param [String] email of the user
    # @param [String] password of the user
    # No return
    def authuser(email, password)
      auth_req = { email: email, password: password }

      begin
        response = @conn.post do |req|
         req.url "/api/v1/users/sign_in"
         req.headers['Content-Type'] = 'application/json'
         req.headers['Accept'] = 'application/json'
         req.body = auth_req.to_json
        end
      rescue Exception => e
        warn("Issue during authentification, bad email or password ?")
        warn(e)
        exit
      end

      json_auth = json(response.body)
      if ! json_auth[:success].nil? && json_auth[:success] == false
        warn(json_auth[:message])
        exit
      end

      @user = json_auth[:user]
      init_vms(@user[:vms])
      init_projects(@user[:projects])
      if @user[:sshkeys][0]
        init_sshkeys(@user[:sshkeys])
      else
        @ssh_key = { name: 'nosshkey' }
      end
    end

    # Get all projects properties
    #
    # @params [Array[Integer]] id array
    # No return
    def init_projects(project_ids)
      @projects = []

      project_ids.each do |project_id|
        response = @conn.get do |req|
          req.url "/api/v1/projects/#{project_id}"
          req.headers = rest_headers
        end

        @projects.push(json(response.body)[:project])
      end
    end

    # Get all vms properties
    #
    # @params [Array[Integer]] id array
    # No return
    def init_vms(vm_ids)
      @vms = []
      
      vm_ids.each do |vm_id|
        response = @conn.get do |req|
          req.url "/api/v1/vms/#{vm_id}"
          req.headers = rest_headers
        end

        @vms.push(json(response.body)[:vm])
      end
    end

    # Get all sshkeys properties
    #
    # @params [Array[Integer]] id array
    # No return
    def init_sshkeys(ssh_ids)
      @ssh_keys = []

      ssh_ids.each do |ssh_id|
        response = @conn.get do |req|
          req.url "/api/v1/sshkeys/#{ssh_id}"
          req.headers = rest_headers
        end

        @ssh_keys << json(response.body)[:sshkey]
        @ssh_key = @ssh_keys.first
      end
    end

    # Get all brands properties
    #
    # @params [Array[Integer]] id array
    # No return
    def init_brands
      response = @conn.get do |req|
        req.url "/api/v1/brands"
        req.headers = rest_headers
      end


      @brands = json(response.body)[:brands]
    end

    # Get all frameworks properties
    #
    # @params [Array[Integer]] id array
    # No return
    def init_frameworks
      response = @conn.get do |req|
        req.url "/api/v1/frameworks"
        req.headers = rest_headers
      end

      @frameworks = json(response.body)[:frameworks]
    end

    # Helper function for parse json call
    #
    # @param body [String] the json on input
    # @return [Hash] the json hashed with symbol
    def json(body)
      JSON.parse(body, symbolize_names: true)
    end

    # Init token generate
    #
    def token
      authuser(@email, @password)
    end

    # Return rest headers well formated
    #
    def rest_headers
      { 'Accept' => 'application/json', 'Content-Type' => 'application/json', 'Authorization' => "Token token=#{@user[:authentication_token]}" }
    end

    # Puts errors on the output
    def error(msg)
      puts msg
      exit 5
    end
  end
end

Mvmc.start(ARGV)
