module API
  module V1
    # Project controller for the rest API (V1).
    #
    # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
    class ProjectsController < ApplicationController
      # Hook who set project object
      before_action :set_project, only: [:show, :update, :destroy]
      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]
      # Check user right for avoid no-authorized access
      before_action :check_admin, only: [:index]
      before_action :only_admin, only: [:create, :destroy, :update]

      # List all projects
      def index
        # Get users associated too
        @projects = Project.includes(:users).all

        # if brand parameter, get only project associated with one brand
        if brand_id = params[:brand] || params[:brand_id]
          brand = Brand.find(brand_id)
          @projects = brand.projects
        end

        # if user parameter, get only all projects for one user
        if user_id = params[:user_id]
          user = User.find(user_id)
          @projects = user.projects
        end

        # if techno parameter, get only all projects for one techno
        if techno_id = params[:techno_id]
          techno = Techno.find(techno_id)
          @projects = techno.projects
        end

        # Json output
        respond_to do |format|
            format.json { render json: @projects, status: 200 }
        end
      end

      # Display details about one project
      def show
        # Json output
        respond_to do |format|
          format.json { render json: @project, status: 200 }
        end
      end

      # Display details about one project from his git path
      def show_by_gitpath
        @project = Project.includes(:users).includes(:technos).find_by_gitpath(params[:gitpath])

        # Json output
        respond_to do |format|
          format.json { render json: @project, status: 200 }
        end
      end

      # Import a new project object from a git path
      def import
        gitpath_import = params['gitpath'] ;
        params['gitpath'] = params['gitpath'].gsub('^.*:[0-9]+','') ;
      end

      # Create a new project object
      def create
        @project = Project.new(project_params)
        
        # Json output
        respond_to do |format|
          if @project.save
            format.json { render json: @project, status: 200 }
          else
            format.json { render json: @project.errors, status: :unprocessable_entity }
          end
        end
      end

      # Apply change for one project object
      def update
        # Json output
        respond_to do |format|
          if @project.update(project_params)
            format.json { render json: @project, status: 200 }
          else
            format.json { render json: @project.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy a project
      def destroy
        @project.destroy

        # Json output
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_project
          @project = Project.includes(:users).includes(:technos).find(params[:id])
        end

        # change ember parameter name for well rails relationships
        # houuuu que c est moche
        def ember_to_rails
          params_p = params[:project]

          params_p[:techno_ids] = params_p[:technos]
          params_p[:user_ids] = params_p[:users]
          params_p[:framework_id] = params_p[:framework]
          params_p[:brand_id] = params_p[:brand]
          params_p[:systemimagetype_id] = params_p[:systemimagetype]
          params_p[:vmsizes_ids] = params_p[:vmsizes]

          params_p.delete(:created_at)
          params_p.delete(:technos)
          params_p.delete(:users)
          params_p.delete(:framework)
          params_p.delete(:brand)
          params_p.delete(:systemimagetype)
          params_p.delete(:vmsizes_ids)

          params[:project] = params_p
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def project_params
          params.require(:project).permit(:name, :gitpath, :isassets, :brand_id, :framework_id, :systemimagetype_id, :enabled, :login, :password, :user_ids => [], :techno_ids => [], :vmsizes_ids => [])
        end
    end
  end
end
