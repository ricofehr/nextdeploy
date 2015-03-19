module API
  module V1
    # VM controller for the rest API (V1).
    #
    # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
    class API::V1::VmsController < ApplicationController
      # Hook who set vm object
      before_action :set_vm, only: [:show, :update, :destroy]
      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]
      # Check user right for avoid no-authorized access
      before_action :check_admin, only: [:create, :destroy, :index]

      # List all vms
      def index
        @vms = Vm.all

        # if project parameters, list only vms about one project
        # If user parameter, list only vms owned by one user
        if project_id = params[:project_id]
          if user_id = params[:user_id]
            @vms = Vm.find_by_user_project(user_id, project_id)
          else
            project = Project.find(project_id)
            @vms = project.vms
          end
        elsif user_id = params[:user_id]
          user = User.find(user_id)
          @vms = user.vms
        end

        # Json format
        respond_to do |format|
            format.json { render json: @vms, status: 200 }
        end
      end

      # Create a new vm request
      def create
        @vm = Vm.new(vm_params)

        # Json response (json error if issue occurs)
        respond_to do |format|
          if @vm.save
            format.json { render json: Vm.find(@vm.id), status: 200 }
          else
            format.json { render json: @vm.errors, status: :unprocessable_entity }
          end
        end
      end

      # Details one vm properties
      def show
        # Json output
        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # Details one vm properties associated with a commit
      def show_by_user_commit
        @vm = Vm.find_by_user_commit(params[:user_id], params[:commit])

        # Json output
        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # List vms for one user
      def show_by_user
        @vms = Vm.find_by_user_id(params[:user_id])

        # Json output
        respond_to do |format|
          format.json { render json: @vms, status: 200 }
        end
      end

      # Stop and destroy a vm
      def destroy
        @vm.destroy

        # Json output
        respond_to do |format|
          format.json { head :no_content }
        end
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_vm
        @vm = Vm.find(params[:id])
      end

      # Use callbacks to share common setup or constraints between actions.
      def set_project
        @vm = Project.find(params[:project_id])
      end

      # change ember parameter name for well rails relationships
      # houuuu que c est moche
      def ember_to_rails
        params_p = params[:vm]

        params_p[:user_id] = params_p[:user] unless params_p[:user_id]
        params_p[:project_id] = params_p[:project] unless params_p[:project_id] 
        params_p[:systemimage_id] = params_p[:systemimage] unless params_p[:systemimage_id]
        params_p[:flavor_id] = params_p[:flavor] unless params_p[:flavor_id]
        params_p[:commit_id] = params_p[:commit] unless params_p[:commit_id]

        params_p.delete(:created_at)
        params_p.delete(:nova_id)
        params_p.delete(:name)
        params_p.delete(:floating_ip)
        params_p.delete(:user)
        params_p.delete(:project)
        params_p.delete(:systemimage)
        params_p.delete(:commit)

        params[:vm] = params_p
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def vm_params
        params.require(:vm).permit(:systemimage_id, :user_id, :commit_id, :project_id, :flavor_id)
      end
    end
  end
end
