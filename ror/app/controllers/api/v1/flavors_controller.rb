module API
  module V1
    # Flavor controller for the rest API (V1).
    # Actually, flavor objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
    class FlavorsController < ApplicationController
      # set flavor object before show function
      before_action :set_flavor, only: [:show]

      # List all flavors
      def index
        @flavors = Flavor.all

        # json output
        respond_to do |format|
            format.json { render json: @flavors, status: 200 }
        end
      end

      # Details about one flavor object
      def show
        # Json output
        respond_to do |format|
            format.json { render json: @flavor, status: 200 }
        end
      end


      private
        # Use callbacks to share common setup or constraints between actions.
        def set_flavor
          @flavor = Flavor.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def flavor_params
          params.require(:flavor).permit(:title, :description)
        end
    end
  end
end
