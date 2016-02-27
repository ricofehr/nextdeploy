module API
  module V1
    # Technotype controller for the rest API (V1).
    # Actually, Technotype objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class TechnotypesController < ApplicationController
      # set technotype object before show function
      before_action :set_technotype, only: [:show]

      # List all technotypes objects
      def index
        @technotypes = Technotype.all

        # Json output
        respond_to do |format|
            format.json { render json: @technotypes, status: 200 }
        end
      end

      # Display details about one technotype object
      def show
        # Json output
        respond_to do |format|
            format.json { render json: @technotype, status: 200 }
        end
      end

      private
        # Use callbacks to share common setup or constraints between actions.
        def set_technotype
          @technotype = Technotype.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def technotype_params
          params.require(:technotype).permit(:name)
        end
    end
  end
end
