module API
  module V1
    # Project controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class ProjectsController < ApplicationController
      # except buildtrigger to rest auth
      before_filter :authenticate_user_from_token!, :except => [:buildtrigger]
      before_filter :authenticate_api_v1_user!, :except => [:buildtrigger]

      # Hook who set project object
      before_action :set_project, only: [:update, :destroy]

      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]

      # Check user right for avoid no-authorized access
      before_action :check_admin, only: [:index]
      before_action :only_create, only: [:create, :destroy]
      before_action :filter_lead, only: [:udpate]

      # List all projects
      #
      def index
        @projects = Project.all

        # if brand parameter, get only project associated with one brand
        if brand_id = params[:brand] || params[:brand_id]
          brand = Brand.find(brand_id)
          @projects = brand.projects
        end

        # if techno parameter, get only all projects for one techno
        if techno_id = params[:techno_id]
          techno = Techno.find(techno_id)
          @projects = techno.projects
        end

        # if user parameter, get only all projects for one user
        if user_id = params[:user_id]
          user = User.find(user_id)
          @projects = user.projects
        end

        respond_to do |format|
          format.json { render json: @projects, status: 200 }
        end
      end

      # Display details about one project
      #
      def show
        if params[:id] != '0'
          @project = Project.find(params[:id])

          respond_to do |format|
            format.json { render json: @project, status: 200 }
          end
        else
          if @user.admin?
            new_pattern
          else
            create_pattern
          end
        end
      end

      # Check project name
      #
      def check_name
        valid = true
        name = params[:name]
        proj_id = params[:id].to_i
        # check if the name is already taken by other projects
        Project.find_each do |proj|
          valid = false if proj.id != proj_id && proj.name == name
        end
        (valid) ? (codestatus = 200) : (codestatus = 410)
        render nothing: true, status: codestatus
      end

      # return default "create project" (pattern for user no-admin who can creates project)
      #
      def create_pattern
        # display file
        if File.exist?('jsons/create_project.json')
          render file: 'jsons/create_project.json', status: 200, content_type: "application/json"
        else
          render nothing: true, status: 500
        end
      end

      # return default "new project" (pattern for admin who creates project)
      #
      def new_pattern
        # display file
        if File.exist?('jsons/new_project.json')
          render file: 'jsons/new_project.json', status: 200, content_type: "application/json"
        else
          render nothing: true, status: 500
        end
      end

      # Display details about one project from his git path
      #
      def show_by_gitpath
        @project = Project.includes(:users).includes(:technos).find_by_gitpath(params[:gitpath])

        respond_to do |format|
          format.json { render json: @project, status: 200 }
        end
      end

      # Import a new project object from a git path
      #
      def import
        gitpath_import = params['gitpath'] ;
        params['gitpath'] = params['gitpath'].sub(/^.*:[0-9]+/, '') ;
      end

      # Create a new project object
      #
      def create
        @project = Project.new(project_params)

        respond_to do |format|
          if @project.save
            format.json { render json: @project, status: 200 }
          else
            format.json { render json: @project.errors, status: :unprocessable_entity }
          end
        end
      end

      # Apply change for one project object
      #
      def update
        respond_to do |format|
          if @project.update(project_params)
            format.json { render json: @project, status: 200 }
          else
            format.json { render json: @project.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy a project
      #
      def destroy
        @project.destroy

        respond_to do |format|
          format.json { head :no_content }
        end
      end

      # Trigger build from gitlab
      #
      def buildtrigger
        branch = params[:ref].sub('refs/heads/', '')
        gitlab_id = params[:project_id]

        # TODO reduce business logic from controller
        @project = Project.find_by(gitlab_id: gitlab_id)

        if @project
          @project.flush_branche(branch)

          @project.vms.select { |vm| vm.status > 1 && vm.is_jenkins && vm.commit.branche.name == branch }.each do |vm|
            vm.buildtrigger
          end
        end

        render nothing: true
      end

      private

      # check right about admin user
      #
      def only_create
        if !@user.is_project_create
          raise Exceptions::GitlabApiException.new("Access forbidden for this user")
        end

        # only admin can change anyone project
        if !@user.admin? && params[:owner_id] && params[:owner_id] != @user.id
          raise Exceptions::GitlabApiException.new("Access forbidden for this user")
        end

        true
      end

      # filter param for project lead
      #
      def filter_lead
        # only project lead or admin can update a project
        if !@user.lead?
          raise Exceptions::GitlabApiException.new("Access forbidden for this user")
        end

        # admin or owner can change all
        if !@user.admin? && params[:owner_id] && params[:owner_id] != @user.id
          params_p = params[:project]
          params[:project] = []
          params[:project][:user_ids] = params_p[:user_ids]
        end

        true
      end

      # Init current object
      #
      def set_project
        @project = Project.includes(:vms, :users, :endpoints).find(params[:id])
      end

      # HACK change ember parameter name for well rails relationships
      #
      def ember_to_rails
        params_p = params[:project]

        if params_p[:owner] && params_p[:owner].empty?
          params_p.delete(:owner)
        end

        params_p[:techno_ids] ||= params_p[:technos]
        params_p[:user_ids] ||= params_p[:users]
        params_p[:owner_id] ||= params_p[:owner]
        params_p[:brand_id] ||= params_p[:brand]
        params_p[:systemimage_ids] ||= params_p[:systemimages]
        params_p[:vmsize_ids] ||= params_p[:vmsizes]

        # permit empty user_ids array if we want disable all users
        params_p[:user_ids] ||= []

        # format gitpath attribute
        gitpath_prefix = "#{Rails.application.config.gitlab_endpoint0.gsub(/https?:\/\//, '')}:/root/"
        params_p[:gitpath].gsub!(gitpath_prefix, '')

        params_p.delete(:created_at)
        params_p.delete(:technos)
        params_p.delete(:users)
        params_p.delete(:owner)
        params_p.delete(:brand)
        params_p.delete(:systemimages)
        params_p.delete(:vmsizes)
        params_p.delete(:endpoints)

        params[:project] = params_p
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def project_params
        params.require(:project).permit(:name, :gitpath, :brand_id, :enabled, :login,
                                        :password, :owner_id, :is_ht, :user_ids => [],
                                        :techno_ids => [], :vmsize_ids => [],
                                        :systemimage_ids => [])
      end

    end
  end
end
