module API
  module V1
    # VM controller for the rest API (V1).
    #
    # @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
    class VmsController < ApplicationController
      # except setupcomplet to rest auth
      before_filter :authenticate_user_from_token!, :except => [:setup_complete,
                                                                :reset_password,
                                                                :refresh_commit]

      before_filter :authenticate_api_v1_user!, :except => [:setup_complete,
                                                            :reset_password,
                                                            :refresh_commit]

      # Hook who set vm object
      before_action :set_vm, only: [:show, :update, :topic, :destroy, :check_status,
                    :boot, :gitpull, :logs, :toggle_auth, :toggle_prod, :toggle_cached,
                    :toggle_ht, :toggle_ci, :toggle_backup, :toggle_cors, :postinstall_display,
                    :postinstall, :reboot, :toggle_ro, :toggle_offline]

      # Hook who check rights before action
      before_action :check_me, only: [:show, :update, :topic, :destroy, :check_status,
                                      :boot, :gitpull, :logs, :toggle_auth, :toggle_prod,
                                      :toggle_cached, :toggle_ht, :toggle_ci, :toggle_backup,
                                      :toggle_cors, :postinstall_display, :postinstall, :reboot,
                                      :toggle_ro, :toggle_offline]

      # Format ember parameters into rails parameters
      before_action :ember_to_rails, only: [:create, :update]

      # Check user right for avoid no-authorized access
      before_action :check_admin, only: [:create, :create_short, :destroy, :boot]

      # Hook who check ci right before tool action
      before_action :check_ci, only: [:gitpull, :postinstall]

      # Hook who reload ci right after tool action
      after_action :reload_ci, only: [:gitpull, :postinstall]


      # List all vms
      #
      def index
        # select only objects allowed by current user
        if project_id = params[:project_id]
          if @user.lead?
            project = Project.find(project_id)
            @vms = project.vms if @user.projects.include?(project)
          else
            @vms = Vm.find_by_user_project(@user.id, project_id)
          end
        else
          if @user.admin?
            @vms = Vm.all
          else
            if @user.lead?
              @vms = @user.projects.flat_map(&:vms).uniq
            else
              if @user.dev?
                @vms = @user.projects.flat_map(&:vms).select do |v|
                  v.user.id == @user.id || v.is_jenkins
                end
              else
                @vms = @user.vms
              end
            end
          end
        end

        respond_to do |format|
          format.json { render json: @vms, status: 200 }
        end
      end

      # Create a new vm request
      #
      def create
        # HACK if user_id in param is guest (a guest cannot clone projects), so we replace sshkey for clone project into vm
        # TODO better for security reason to replace with generic key specific for the project
        user_vm = User.find(params[:vm][:user_id])
        user_vm.copy_sshkey_modem(@user.email) if user_vm.guest?

        @vm = Vm.new(vm_params)

        respond_to do |format|
          if @vm.save
            format.json { render json: Vm.find(@vm.id), status: 200 }
          else
            format.json { render json: @vm.errors, status: :unprocessable_entity }
          end
        end
      end

      # Create a new vm request in short way
      #
      def create_short
        # HACK if user_id in param is guest (a guest cannot clone projects), so we replace sshkey for clone project into vm
        # TODO better for security reason to replace with generic key specific for the project
        user_vm = User.find(params[:vm][:user_id])
        user_vm.copy_sshkey_modem(@user.email) if user_vm.guest?

        @vm = Vm.new(vm_params)

        respond_to do |format|
          if @vm.save
            @vm.init_defaulturis
            @vm.boot
            format.json { render json: Vm.find(@vm.id), status: 200 }
          else
            format.json { render json: @vm.errors, status: :unprocessable_entity }
          end
        end
      end

      # boot the vm or update user !
      #
      def update
        if @vm.nova_id.nil?
          @vm.boot
        else
          @vm.change_user(params[:vm][:user_id]) if @user.lead?
        end

        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # Change topic content
      #
      def topic
        @vm.set_topic(params[:topic])
        render nothing: true
      end

      # Boot vm
      #
      def boot
        @vm.boot
        # Json output
        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # Toggle ro parameter
      #
      def toggle_ro
        @vm.toggle_ro
        render nothing: true
      end

      # Toggle auth parameter
      #
      def toggle_auth
        @vm.toggle_auth
        render nothing: true
      end

      # Toggle isht parameter
      #
      def toggle_ht
        @vm.toggle_ht
        render nothing: true
      end

      # Toggle isci parameter
      #
      def toggle_ci
        @vm.toggle_ci
        render nothing: true
      end

      # Toggle isbackup parameter
      #
      def toggle_backup
        @vm.toggle_backup
        render nothing: true
      end

      # Toggle prod parameter
      #
      def toggle_prod
        @vm.toggle_prod
        render nothing: true
      end

      # Toggle cors parameter
      #
      def toggle_cors
        @vm.toggle_cors
        render nothing: true
      end

      # Toggle offline parameter
      #
      def toggle_offline
        @vm.toggle_offline
        render nothing: true
      end

      # Toggle cached parameter
      #
      def toggle_cached
        @vm.toggle_cached
        render nothing: true
      end

      # Details one vm properties
      #
      def show
        @vm.init_vnc_url

        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # Details one vm properties associated with a commit
      #
      def show_by_user_commit
        @vm = Vm.find_by_user_commit(params[:user_id], params[:commit])

        respond_to do |format|
          format.json { render json: @vm, status: 200 }
        end
      end

      # List vms for one user
      #
      def show_by_user
        @vms = Vm.find_by_user_id(params[:user_id])

        respond_to do |format|
          format.json { render json: @vms, status: 200 }
        end
      end

      # Stop and destroy a vm
      #
      def destroy
        # ensute we have permission to destroy the vm
        if  !@vm.prod? &&
            (@user.vms.any? { |v| v.id == @vm.id } ||
            (@user.lead? && @vm.project.vms.any? { |v| v.id == @vm.id && !@vm.user.admin? }) ||
            @user.admin?)

            @vm.destroy

            respond_to do |format|
              format.json { head :no_content }
            end
        else
          respond_to do |format|
            format.json { head :no_content, status: 403 }
          end
        end
      end

      # Compute build time and update status field
      #
      def setup_complete
        @vm = Vm.find_by(name: params[:name])
        @vm.setup_complete if @vm
        render nothing: true
      end

      # Update vm password
      #
      def reset_password
        @vm = Vm.find_by(name: params[:name])
        @vm.reset_password(params[:password]) if (@vm)
        render nothing: true
      end

      # Check status, get 200 if vm is running
      #
      def check_status
        (@vm.status > 1) ? (codestatus = 200) : (codestatus = 410)
        render plain: @vm.buildtime, status: codestatus
      end

      # Execute gitpull cmd into vm
      #
      def gitpull
        ret = @vm.gitpull
        render plain: ret[:message], status: ret[:status]
      end

      # Execute display of postinstall cmd into vm
      #
      def postinstall_display
        ret = @vm.postinstall_display
        render plain: ret[:message], status: ret[:status]
      end

      # Execute postinstall cmd into vm
      #
      def postinstall
        ret = @vm.postinstall
        render plain: ret[:message], status: ret[:status]
      end

      # Execute a reboot
      #
      def reboot
        @vm.reboot(params[:type])
        render nothing: true
      end

      # Display current logs for the vm
      #
      def logs
        ret = @vm.logs
        render plain: ret[:message], status: ret[:status]
      end

      # Refresh commit id for vm
      #
      def refresh_commit
        @vm = Vm.find_by(name: params[:name])
        if @vm
          @vm.refresh_commit(params[:commit_id])
        else
          Rails.logger.warn("Refreshcommit, no vm identified by name: #{params[:name]}")
        end

        render nothing: true
      end

      private

      # check if ci is enabled for lock mecanism
      #
      def check_ci
        ncp = 0
        if @vm.is_ci
          @vm.toggle_ci(false)
          # wait max 10min to let ci finish his work
          while @vm.checkci do
            break if ncp == 5
            sleep(120)
            ncp += 1
          end
          @vm.clearci
        end

        return true
      end

      # reload ci if enabled for lock mecanism
      #
      def reload_ci
        @vm.reload
        @vm.generate_hiera if @vm.is_ci
      end

      # Init current object
      #
      def set_vm
        @vm = Vm.includes(:uris, :user, :project).find(params[:id])
      end

      # ensure that only admin, lead or hisself can execute action
      #
      def check_me
        isme = false
        if @user.lead?
          isme = @user.projects.any? { |project| project.id == @vm.project.id }
        else
          isme = (@user.id == @vm.user.id)
        end

        raise Exceptions::NextDeployException.new("Access forbidden for this user") unless isme
      end

      # HACK change ember parameter name for well rails relationships
      #
      def ember_to_rails
        params_p = params[:vm]

        params_p[:user_id] ||= params_p[:user]
        params_p[:project_id] ||= params_p[:project]
        params_p[:systemimage_id] ||= params_p[:systemimage]
        params_p[:vmsize_id] ||= params_p[:vmsize]
        params_p[:commit_id] ||= params_p[:commit]
        params_p[:techno_ids] ||= params_p[:technos]

        params_p.delete(:created_at)
        params_p.delete(:nova_id)
        params_p.delete(:floating_ip)
        params_p.delete(:thumb)
        params_p.delete(:user)
        params_p.delete(:project)
        params_p.delete(:systemimage)
        params_p.delete(:commit)
        params_p.delete(:vmsize)
        params_p.delete(:technos)
        params_p.delete(:vnc_url)
        params_p.delete(:termpassword)
        params_p.delete(:status)

        params[:vm] = params_p
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      #
      def vm_params
        params.require(:vm).permit(:systemimage_id, :user_id, :commit_id, :project_id,
                                   :vmsize_id, :name, :topic, :is_auth, :htlogin,
                                   :htpassword, :layout, :is_prod, :is_cached,
                                   :is_ht, :is_ci, :is_cors, :is_ro, :is_jenkins,
                                   :is_offline, :techno_ids => [])
      end

    end
  end
end
