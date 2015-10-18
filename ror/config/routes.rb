# Rails Router
# @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
Rails.application.routes.draw do

  # Api v1 Controllers
  namespace :api do
    namespace :v1 do

      # Some custom routes
      get '/projects/git/:gitpath' => 'projects#show_by_gitpath', as: 'project_by_gitpath', constraints: { gitpath: /.+/ }
      get '/users/email/:email' => 'users#show_by_email', as: 'user_by_email', constraints: { email: /.+@.+\..*/ }
      get '/users/:id' => 'users#show', as: 'user', constraints: { id: /\d+/ }
      get '/user' => 'users#show_current', as: 'user_current'
      get '/user/ovpnca' => 'users#dl_openvpn_ca', as: 'dl_ocpnca'
      get '/user/ovpnkey' => 'users#dl_openvpn_key', as: 'dl_ovpnkey'
      get '/user/ovpncrt' => 'users#dl_openvpn_crt', as: 'dl_ovpncrt'
      get '/user/ovpnconf' => 'users#dl_openvpn_conf', as: 'dl_ovpnconf'
      get '/group' => 'groups#show_current', as: 'group_current'
      get '/vms/user/:user_id/:commit' => 'vms#show_by_user_commit', as: 'vms_by_user_commit', constraints: { commit: /\d+-[a-zA-Z0-9]+-([a-z0-9]{40})/, user_id: /\d+/ }
      get '/vms/user/:user_id' => 'vms#show_by_user', as: 'vms_by_user', constraints: { user_id: /\d+/ }
      get '/systemimages/type/:systemimagetype_id' => 'systemimages#index_by_type', as: 'systemimages_by_type', constraints: { systemimagetype_id: /\d+/ }
      put '/vms/:name/setupcomplete' => 'vms#setupcomplete', as: 'vm_setupcomplete', constraints: { name: /[a-zA-Z0-9-]+/ }
      get '/vms/:id/setupcomplete' => 'vms#check_status', as: 'vm_check_status', constraints: { id: /\d+/ }

      # Complete routes
      with_options only: [:create, :index, :show, :update, :destroy] do |list_only|
        list_only.resources :groups
        list_only.resources :brands
        list_only.resources :projects
        list_only.resources :vms
        list_only.resources :sshkeys
        list_only.resources :users
      end

      # Read-Only route
      with_options only: [:index, :show] do |list_only|
        list_only.resources :branches
        list_only.resources :commits
        list_only.resources :systemimagetypes
        list_only.resources :technos
        list_only.resources :vmsizes
        list_only.resources :frameworks
        list_only.resources :systemimages
      end

      # Session route
      devise_for(:users, :controllers => { :sessions => "api/v1/sessions" } )
    end
  end
end
