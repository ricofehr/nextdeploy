module API
  module V1
    # Techno controller for the rest API (V1).
    # Actually, techno objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class TechnosController < ApplicationController
      # set techno object before show function
      before_action :set_techno, only: [:show]

      # List all technos objects
      #
      def index
        # If technotype parameter, get all technos for one type
        if technotype_id = params[:technotype_id]
          @technos = Technotype.includes(:technos).find(technotype_id).technos
        else
          @technos = Techno.all
        end

        respond_to do |format|
          format.json { render json: @technos, status: 200 }
        end
      end

      # Display details about one techno object
      #
      def show
        respond_to do |format|
          format.json { render json: @techno, status: 200 }
        end
      end

      private

      # Init current object
      #
      def set_techno
        @techno = Techno.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def techno_params
        params.require(:techno).permit(:name, :puppetclass)
      end

    end
  end
end
