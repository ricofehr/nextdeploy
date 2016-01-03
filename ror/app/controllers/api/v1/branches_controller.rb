module API
  module V1
    # Branche controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class BranchesController < ApplicationController
      # Set branche object before show function
      before_action :set_branche, only: [:show]

      # List all branches for a project
      def index
        @branches = Branche.all(params[:project_id])

        respond_to do |format|
            format.json { render json: @branches, status: 200 }
        end
      end

      # Return one branche with his details
      def show
        respond_to do |format|
          format.json { render json: @branche, status: 200 }
        end
      end


      private
        # Use callbacks to share common setup or constraints between actions.
        def set_branche
          @branche = Branche.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def branch_params
          params.require(:branch).permit(:project_id, :name)
        end
    end
  end
end