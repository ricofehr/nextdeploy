module API
  module V1
    # Endpoint controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class EndpointsController < ApplicationController
      # Hook who set endpoint object
      before_action :set_endpoint, only: [:show, :update, :destroy]
      # Check user right for avoid no-authorized access
      before_action :only_create, only: [:create, :destroy]
      before_action :filter_lead, only: [:update]
      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]

      # List all endpoints
      def index
        # select only objects allowed by current user
        if @user.admin?
          @endpoints = Endpoint.all
        else
          projects = @user.projects
          if projects
            @endpoints = projects.flat_map(&:endpoints).uniq
          end
        end

        # Json output
        respond_to do |format|
            format.json { render json: @endpoints || [], status: 200 }
        end
      end

      # Details about one endpoint
      def show
        # Json output
        respond_to do |format|
          format.json { render json: @endpoint, status: 200 }
        end
      end

      # Create a new endpoint
      def create
        @endpoint = Endpoint.new(endpoint_params)
        @endpoint.install_endpoint if @is_install

        # Json output
        respond_to do |format|
          if @endpoint.save
            format.json { render json: @endpoint, status: 200 }
          else
            format.json { render json: @endpoint.errors, status: :unprocessable_entity }
          end
        end
      end

      # Apply changes about one endpoint
      def update
        # Json output
        respond_to do |format|
          if @endpoint.update(endpoint_params)
            format.json { render json: @endpoint, status: 200 }
          else
            format.json { render json: @endpoint.errors, status: :unprocessable_entity }
          end
        end
      end

      # Destroy one endpoint
      def destroy
        @endpoint.destroy

        # Json output
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private
       # check right about admin user
        def only_create
          if ! @user.is_project_create
            raise Exceptions::GitlabApiException.new("Access forbidden for this user")
          end

          # only admin can change anyone project
          if ! @user.admin? && params[:owner_id] && params[:owner_id] != @user.id
            raise Exceptions::GitlabApiException.new("Access forbidden for this user")
          end

          true
        end

        # filter param for project lead
        def filter_lead
          # only project lead or admin can update a project
          if ! @user.lead?
            raise Exceptions::GitlabApiException.new("Access forbidden for this user")
          end

          true
        end

        # Use callbacks to share common setup or constraints between actions.
        def set_endpoint
          @endpoint = Endpoint.find(params[:id])
        end

        # change ember parameter name for well rails relationships
        # houuuu que c est moche
        def ember_to_rails
          params_p = params[:endpoint]

          params_p[:project_id] ||= params_p[:project]
          params_p[:framework_id] ||= params_p[:framework]

          @is_install = params_p[:is_install] ? true : false
          params_p.delete(:is_install)

          params[:endpoint] = params_p
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def endpoint_params
          params.require(:endpoint).permit(:prefix, :path, :envvars, :aliases, :project_id,
                                           :framework_id, :is_install, :port, :ipfilter,
                                           :customvhost, :is_sh, :is_import, :is_main, :is_ssl)
        end
    end
  end
end
