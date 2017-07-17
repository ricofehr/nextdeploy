module API
  module V1
    # Framework controller for the rest API (V1).
    # Actually, framework objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class FrameworksController < ApplicationController
      # set framework object before show function
      before_action :set_framework, only: [:show]

      # List all frameworks
      #
      def index
        # select only objects allowed by current user
        if @user.is_project_create
          @frameworks = Framework.all
        else
          @frameworks = @user.projects.flat_map(&:endpoints).flat_map(&:framework).uniq
        end

        # HACK need an AR array (even empty) for AMS
        @frameworks = Framework.none if @frameworks.length == 0

        respond_to do |format|
          format.json { render json: @frameworks, status: 200 }
        end
      end

      # Details about one framework object
      #
      def show
        respond_to do |format|
          format.json { render json: @framework, status: 200 }
        end
      end

      private

      # Init current object
      #
      def set_framework
        @framework = Framework.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def framework_params
        params.require(:framework).permit(:name)
      end

    end
  end
end
