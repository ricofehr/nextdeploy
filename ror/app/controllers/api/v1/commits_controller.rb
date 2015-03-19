module API
  module V1
    # Commit controller for the rest API (V1).
    #
    # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
    class CommitsController < ApplicationController
      # set commit object before show function
      before_action :set_commit, only: [:show]

      # List all commits for a branch id
      def index
        @commits = Commits.all(params[:branche_id])

        # Json output
        respond_to do |format|
            format.json { render json: @commits, status: 200 }
        end
      end

      # details about one commit
      def show
        respond_to do |format|
          format.json { render json: @commit, status: 200 }
        end
      end


      private
        # Use callbacks to share common setup or constraints between actions.
        def set_commit
          @commit = Commit.find(params[:id])
        end

        # Never trust parameters from the scary internet, only allow the white list through.
        def commit_params
          params.require(:commit).permit(:project_id, :branch, :commit)
        end
    end
  end
end