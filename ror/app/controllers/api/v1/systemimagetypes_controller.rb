module API
  module V1
    # Systemimagetype controller for the rest API (V1).
    # Actually, Systemimagetype objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class SystemimagetypesController < ApplicationController
      # set systemimagetype object before show function
      before_action :set_systemimagetype, only: [:show]

      # List all systemimagetypes objects
      #
      def index
        @systemimagetypes = Systemimagetype.all

        respond_to do |format|
          format.json { render json: @systemimagetypes, status: 200 }
        end
      end

      # Display details about one systemimagetype object
      #
      def show
        respond_to do |format|
          format.json { render json: @systemimagetype, status: 200 }
        end
      end

      private

      # Init current object
      #
      def set_systemimagetype
        @systemimagetype = Systemimagetype.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def systemimagetype_params
        params.require(:systemimagetype).permit(:name)
      end

    end
  end
end
