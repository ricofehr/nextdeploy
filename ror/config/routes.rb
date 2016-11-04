# Rails Router
# @author Eric Fehr (ricofehr@nextdeploy.io, github: ricofehr)
Rails.application.routes.draw do

  # Api v1 Controllers
  namespace :api do
    namespace :v1 do
      # Session route
      devise_for(:users, :controllers => { :sessions => "api/v1/sessions" }, :skip => [:registrations, :passwords] )

      # Some custom routes
      get '/projects/git/:gitpath' => 'projects#show_by_gitpath', as: 'project_by_gitpath', constraints: { gitpath: /.+/ }
      get '/projects/:id/name/:name' => 'projects#check_name', as: 'project_check_name', constraints: { id: /\d+/, name: /[a-zA-Z0-9_\.-]+/ }
      get '/users/:id/email/:email' => 'users#check_email', as: 'user_check_email', constraints: { id: /\d+/, email: /.+@.+\..*/ }
      get '/users/email/:email' => 'users#show_by_email', as: 'user_by_email', constraints: { email: /.+@.+\..*/ }
      get '/users/:id' => 'users#show', as: 'user', constraints: { id: /\d+/ }
      get '/user' => 'users#show_current', as: 'user_current'
      get '/user/forgot/:email' => 'users#forgot', as: 'user_forgot_password', constraints: { email: /.+@.+\..*/ }
      get '/user/ovpnca' => 'users#dl_openvpn_ca', as: 'dl_ocpnca'
      get '/user/ovpnkey' => 'users#dl_openvpn_key', as: 'dl_ovpnkey'
      get '/user/ovpncrt' => 'users#dl_openvpn_crt', as: 'dl_ovpncrt'
      get '/user/ovpnconf' => 'users#dl_openvpn_conf', as: 'dl_ovpnconf'
      get '/group' => 'groups#show_current', as: 'group_current'
      get '/vms/user/:user_id/:commit' => 'vms#show_by_user_commit', as: 'vms_by_user_commit', constraints: { commit: /\d+-[a-zA-Z0-9]+-([a-z0-9]{40})/, user_id: /\d+/ }
      get '/vms/user/:user_id' => 'vms#show_by_user', as: 'vms_by_user', constraints: { user_id: /\d+/ }
      get '/systemimages/type/:systemimagetype_id' => 'systemimages#index_by_type', as: 'systemimages_by_type', constraints: { systemimagetype_id: /\d+/ }
      put '/vms/:name/setupcomplete' => 'vms#setupcomplete', as: 'vm_setupcomplete', constraints: { name: /[a-zA-Z0-9-]+/ }
      put '/vms/:name/resetpassword/:password' => 'vms#resetpassword', as: 'vm_resetpassword', constraints: { name: /[a-zA-Z0-9-]+/, password: /[a-zA-Z0-9-]+/ }
      put '/vms/:name/commit' => 'vms#refreshcommit', as: 'vm_refreshcommit', constraints: { name: /[a-zA-Z0-9-]+/ }
      get '/vms/:id/setupcomplete' => 'vms#check_status', as: 'vm_check_status', constraints: { id: /\d+/ }
      post '/vms/short' => 'vms#create_short', as: 'create_short'
      post '/vms/:id/import' => 'vms#import', as: 'vm_import', constraints: { id: /\d+/ }
      post '/vms/:id/export' => 'vms#export', as: 'vm_export', constraints: { id: /\d+/ }
      post '/vms/:id/gitpull' => 'vms#gitpull', as: 'vm_gitpull', constraints: { id: /\d+/ }
      post '/vms/:id/postinstall_display' => 'vms#postinstall_display', as: 'vm_postinstall_display', constraints: { id: /\d+/ }
      post '/vms/:id/postinstall' => 'vms#postinstall', as: 'vm_postinstall', constraints: { id: /\d+/ }
      post '/vms/:id/logs' => 'vms#logs', as: 'vm_logs', constraints: { id: /\d+/ }
      post '/vms/:id/boot' => 'vms#boot', as: 'vm_boot', constraints: { id: /\d+/ }
      post '/vms/:id/toggleauth' => 'vms#toggleauth', as: 'vm_toggleauth', constraints: { id: /\d+/ }
      post '/vms/:id/toggleprod' => 'vms#toggleprod', as: 'vm_toggleprod', constraints: { id: /\d+/ }
      post '/vms/:id/togglecached' => 'vms#togglecached', as: 'vm_togglecached', constraints: { id: /\d+/ }
      post '/vms/:id/toggleht' => 'vms#toggleht', as: 'vm_toggleht', constraints: { id: /\d+/ }
      post '/vms/:id/toggleci' => 'vms#toggleci', as: 'vm_toggleci', constraints: { id: /\d+/ }
      post '/vms/:id/togglebackup' => 'vms#togglebackup', as: 'vm_togglebackup', constraints: { id: /\d+/ }
      post '/vms/:id/togglecors' => 'vms#togglecors', as: 'vm_togglecors', constraints: { id: /\d+/ }
      post '/uris/:id/import' => 'uris#import', as: 'uri_import', constraints: { id: /\d+/ }
      post '/uris/:id/export' => 'uris#export', as: 'uri_export', constraints: { id: /\d+/ }
      post '/uris/:id/npm' => 'uris#npm', as: 'uri_npm', constraints: { id: /\d+/ }
      post '/uris/:id/nodejs' => 'uris#nodejs', as: 'uri_nodejs', constraints: { id: /\d+/ }
      post '/uris/:id/reactjs' => 'uris#reactjs', as: 'uri_reacts', constraints: { id: /\d+/ }
      post '/uris/:id/mvn' => 'uris#mvn', as: 'uri_mvn', constraints: { id: /\d+/ }
      post '/uris/:id/composer' => 'uris#composer', as: 'uri_composer', constraints: { id: /\d+/ }
      post '/uris/:id/drush' => 'uris#drush', as: 'uri_drush', constraints: { id: /\d+/ }
      post '/uris/:id/sfcmd' => 'uris#sfcmd', as: 'uri_sfcmd', constraints: { id: /\d+/ }
      post '/uris/:id/listscript' => 'uris#listscript', as: 'uri_listscript', constraints: { id: /\d+/ }
      post '/uris/:id/script' => 'uris#script', as: 'uri_script', constraints: { id: /\d+/ }
      post '/uris/:id/logs' => 'uris#logs', as: 'uri_logs', constraints: { id: /\d+/ }
      post '/uris/:id/clearvarnish' => 'uris#clearvarnish', as: 'uri_clearvarnish', constraints: { id: /\d+/ }

      # branche routes
      get '/branches/:id' => 'branches#show', constraints: { id: /.+/ }
      get '/branches' => 'branches#index'

      # commits routes
      get '/commits/:id' => 'commits#show', constraints: { id: /.+/ }
      get '/commits' => 'commits#index'

      # vmtechnos routes
      get '/supervises' => 'supervises#index', constraints: { vm_id: /\d+/ }
      post '/supervises/:vm_id/status' => 'supervises#status', constraints: { vm_id: /\d+/ }

      # Complete routes
      with_options only: [:create, :index, :show, :update, :destroy] do |list_only|
        list_only.resources :groups
        list_only.resources :brands
        list_only.resources :projects
        list_only.resources :endpoints
        list_only.resources :uris
        list_only.resources :vms
        list_only.resources :sshkeys
        list_only.resources :users
      end

      # Read-Only route
      with_options only: [:index, :show] do |list_only|
        list_only.resources :systemimagetypes
        list_only.resources :technotypes
        list_only.resources :technos
        list_only.resources :vmsizes
        list_only.resources :frameworks
        list_only.resources :systemimages
        list_only.resources :hpmessages
      end
    end
  end
end
