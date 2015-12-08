module API
  module V1
    # Vmsize controller for the rest API (V1).
    # Actually, vmsize objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
    class VmsizesController < ApplicationController
      # set vmsize object before show function
      before_action :set_vmsize, only: [:show]

      # List all vmsizes
      def index
        # select only objects allowed by current user
        if @user.is_project_create
          @vmsizes = Vmsize.all
        else
          @vmsizes = []
          projects = @user.projects
          if projects
            @vmsizes = [] << projects.map { |project| project.vmsizes }
            @vmsizes.flatten!.uniq!
          end
        end

        # json output
        respond_to do |format|
            format.json { render json: @vmsizes, status: 200 }
        end
      end

      # Details about one vmsize object
      def show
        # Json output
        respond_to do |format|
            format.json { render json: @vmsize, status: 200 }
        end
      end


      private
        # Use callbacks to share common setup or constraints between actions.
        def set_vmsize
          @vmsize = Vmsize.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def vmsize_params
          params.require(:vmsize).permit(:title, :description)
        end
    end
  end
end
