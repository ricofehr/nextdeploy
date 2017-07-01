module API
  module V1
    # VmTechnos controller for the rest API (V1).
    # Actually, Technotype objects are managed directly in database.
    # Controller is needed only for display properties into json format for rest compliance
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class SupervisesController < ApplicationController
      # List all vmtechnotypes objects for a vm
      def index
        @supervises = []
        #.find(params[:vm_id]).vm_technos

        if @user.admin?
          @supervises = Supervise.all
        else
          if @user.lead?
            projects = @user.projects
            if projects
              vms = projects.flat_map(&:vms).uniq
              @supervises = vms.flat_map(&:supervises).uniq if vms.size
            end
          else
            vms = @user.vms
            @supervises = vms.flat_map(&:supervises).uniq if vms.size
          end
        end

        # Json output
        respond_to do |format|
            format.json { render json: @supervises, status: 200 }
        end
      end

      # Execute datas export into vm
      def status
        # ensure :satus is boolean
        status = (params[:status] == 1 || params[:status] == true) ? true : false

        changed = Supervise.find_by_foreigns(params[:vm_id], params[:techno_id]).first.change_status(status)
        if changed == 1
          SuperviseMailer.supervise_email(@user, Vm.find(params[:vm_id]), Techno.find(params[:techno_id]), status).deliver
        end

        render nothing: true
      end

      private
        # Never trust parameters from the scary internet, only allow the white list through.
        def technotype_params
          params.require(:supervise).permit(:vm_id, :techno_id, :status)
        end
    end
  end
end
