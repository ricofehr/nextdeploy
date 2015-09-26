module Apiexternal
  # Osapi manages rest request to openstack API
  #
  # @author Eric Fehr (eric.fehr@publicis-modem.fr, github: ricofehr)
  class Osapi

    #class attributes (scope: private)
    @conn = {}
    @token = nil
    @tenant = nil
    @nets = {}

    # Constructor. Initialize the four class attributes.
    #
    # No params
    # No return
    def initialize
      init_api
    end

    # Make a rest call to openstack for boot a new virtual machine
    #
    # @param vm_name [String] the vm name identifier
    # @param glance_id [String] the id of systemimage associated to the vm
    # @param ssh_key [String] the name of ssh_key associated to the vm
    # @param flavor [String] the name of resource markup associated to the vm
    # @raise Exceptions::OSApiException if error occurs
    # @return [String] the id of nova vm just created
    def boot_vm(vm_name, glance_id, ssh_key, flavor, user_data)

      begin
        #create new port ip and get flavor_id
        port_uuid = create_port(@nets[:private], vm_name)
        flav_id = get_flavor(flavor)
      rescue Exceptions::OSApiException => oe
        raise oe
      end

      #json request for boot new vm
      boot_req = { server:
                   {
                      name: vm_name,
                      imageRef: glance_id ,
                      flavorRef: flav_id,
                      networks: [{ port: port_uuid }],
                      security_groups: [{ name: "default" }],
                      user_data: user_data
                   }
               }

      # add key_name parameter if ssh key is associated to current user
      boot_req[:server][:key_name] = ssh_key unless ssh_key.nil? || ssh_key.empty?

      response = @conn[:nova].post do |req|
        req.url "/v2/#{@tenant}/servers"
        req.headers = self.headers
        req.body = boot_req.to_json
      end

      raise Exceptions::OSApiException.new("boot new vm failed, error code: #{response.status}, #{response.body}, #{boot_req.to_json}") if response.status != 202

      #get nova_id value
      nova_id = json(response.body)[:server][:id]
      begin
        add_floating_ip(port_uuid)
      rescue Exceptions::OSApiException => oe
        oe.log
      end

      return nova_id
    end

    # Rest call to openstack for getting floatingip from the nova identifier
    #
    # @param nova_id [String] the nova identifier for the vm
    # @raise Exceptions::OSApiException if error occurs
    # @return [Hash] the floatingip hash associated to the vm
    def get_floatingip(nova_id)
      response = @conn[:nova].get do |req|
        req.url "/v2/#{@tenant}/os-floating-ips"
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("Get Api request on /v2.0/floatingips: #{response.status}") if response.status != 200

      begin
        floatingip_id = json(response.body)[:floating_ips].detect { |net| net[:instance_id] == nova_id }
      rescue
        raise Exceptions::OSApiException.new("No floatingips")
      end

      #raise Exceptions::OSApiException.new("No floatingip associated with the vm #{nova_id}") if floatingip_id.nil?

      return floatingip_id
    end

    # Make a rest call to openstack for add an ssh-key
    #
    # @param name [String] the key-name identifier
    # @param key [String] the public key
    # @raise Exceptions::OSApiException if error occurs
    # No return.
    def add_sshkey(name, key)
      ssh_req = { keypair:
                   {
                     name: name,
                     public_key: key
                   }
              }

      response = @conn[:nova].post do |req|
        req.url "/v2/#{@tenant}/os-keypairs"
        req.headers = self.headers
        req.body = ssh_req.to_json
      end

      raise Exceptions::OSApiException.new("add ssh_key post request failed for #{name}, error code: #{response.status}") if response.status != 200
    end

    # Make a rest call to openstack for delete virtual machine
    #
    # @param nova_id [String] the vm identifier for nova
    # @raise Exceptions::OSApiException if error occurs
    # No return
    def delete_vm(nova_id)
      begin
        floating_ip = get_floatingip(nova_id)
        remove_floatingip(nova_id, floating_ip[:ip]) if floating_ip
        delete_port(get_port_uuid(nova_id))
      rescue Exceptions::OSApiException => oe
        oe.log
      end

      response = @conn[:nova].delete do |req|
        req.url "/v2/#{@tenant}/servers/#{nova_id}"
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("Delete Api request on /v2/#{@tenant}/servers/#{nova_id}: #{response.status}") if response.status != 204
    end

    # Make a rest call to openstack for delete an ssh-key
    #
    # @param name [String] the key identifier
    # @raise Exceptions::OSApiException if error occurs
    # No return.
    def delete_sshkey(name)
      response = @conn[:nova].delete do |req|
        req.url "/v2/#{@tenant}/os-keypairs/#{name}"
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("Delete request on /v2/#{@tenant}/os-keypairs/#{name}: #{response.status}") if response.status != 202
    end

    protected

    def headers
      { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'X-Auth-Token' => @token }
    end

    private

    # Init the class attributes
    #
    # No params
    # No return
    def init_api

      begin
       auth_token
      rescue Exceptions::MvmcException => me
        me.log_e
      end

      @conn = Hash.new
      init_conn_neutron
      init_conn_nova

      @nets = Hash.new
      init_networks
    end

    # Get a token for the authentification on openstack api
    #
    # No params
    # @raise Exceptions::OSApiException if error occurs
    # No return
    def auth_token
      username = ENV['OS_USERNAME']
      password = ENV['OS_PASSWORD']
      tenant_name = ENV['OS_TENANT_NAME']

      conn_auth = Faraday.new(:url => "#{Rails.application.config.os_endpoint}") do |faraday|
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      auth_req = { auth:
                    { tenantName: tenant_name,
                      passwordCredentials:
                      { username: username, password: password }
                    }
                  }

      response = conn_auth.post do |req|
        req.url "/v2.0/tokens"
        req.headers['Content-Type'] = 'application/json'
        req.headers['Accept'] = 'application/json'
        req.body = auth_req.to_json
      end

      raise Exceptions::OSApiException.new("Auth failed with username #{username}") if response.status != 200

      @token = json(response.body)[:access][:token][:id]
      @tenant = json(response.body)[:access][:token][:tenant][:id]
    end

    # Set the neutron endpoint for openstack api
    #
    # No params
    # No return
    def init_conn_neutron
      @conn[:neutron] = Faraday.new(:url => "#{Rails.application.config.os_endpoint_neutron}") do |faraday|
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    # Set the nova endpoint for openstack api
    #
    # No params
    # No return
    def init_conn_nova
      @conn[:nova] = Faraday.new(:url => "#{Rails.application.config.os_endpoint_nova}") do |faraday|
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end


    # Set the cinder endpoint for openstack api
    #
    # No params
    # No return
    def init_conn_cinder
      @conn[:cinder] = Faraday.new(:url => "#{Rails.application.config.os_endpoint_cinder}") do |faraday|
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    # Rest call to openstack for inits nets hash with filling public/private networks
    #
    # No params
    # No return
    def init_networks
      response = @conn[:neutron].get do |req|
        req.url '/v2.0/networks'
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("/v2.0/networks failed, error code: #{response.status}") if response.status != 200

      begin
        @nets[:private] = json(response.body)[:networks].detect { |net| net[:name] == "private" }[:id]
        @nets[:public] = json(response.body)[:networks].detect { |net| net[:name] == "public" }[:id]
      rescue
        raise Exceptions::OSApiException.new('/v2.0/networks empty')
      end

      raise Exceptions::OSApiException.new('no private/public from /v2.0/networks') if @nets[:private].nil? || @nets[:public].nil?
    end

    # Rest call to openstack for getting flavor id from his name
    #
    # @param name [String] the flavor title
    # @raise Exceptions::OSApiException if error occurs
    # @return [String] the identifier of the flavor
    def get_flavor(name)
      response = @conn[:nova].get do |req|
        req.url "/v2/#{@tenant}/flavors"
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("Get flavors request failed, error code: #{response.status}") if response.status != 200

      begin
        flav = json(response.body)[:flavors].detect { |net| net[:name] == name }
      rescue
        raise Exceptions::OSApiException.new("No flavors returned by /v2/#{options[:tenant]}/flavors")
      end

      return flav[:id] if flav
      raise Exceptions::OSApiException.new("No #{name} flavor returned by /v2/#{options[:tenant]}/flavors")
    end

    # Rest call to openstack for getting port_uuid from the nova identifier
    #
    # @param nova_id [String] the nova identifier for the vm
    # @raise Exceptions::OSApiException if error occurs
    # @return [String] the port_uuid associated to the vm
    def get_port_uuid(nova_id)
      response = @conn[:neutron].get do |req|
        req.url '/v2.0/ports'
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("Get Api request failed on /v2.0/ports: #{response.status}") if response.status != 200

      begin
        port_uuid = json(response.body)[:ports].detect { |net| net[:device_id] == nova_id }
      rescue
        raise Exceptions::OSApiException.new("No ports")
      end
      raise Exceptions::OSApiException.new("No port associated with vm #{nova_id}") if port_uuid.nil?

      return port_uuid[:id]
    end

    # Rest call to openstack for create ip port for the vm
    #
    # @param net_id [String] the private network id where the vm is binding
    # @param vm_name [String] unique string identifying the vm
    # @raise Exceptions::OSApiException if error occurs
    # @return [String] the port_uuid associated to the vm
    def create_port(net_id, vm_name)
      port_req = { port:
                    { network_id: net_id, name: "port-#{vm_name}", admin_state_up: true }
                 }

      response = @conn[:neutron].post do |req|
        req.url '/v2.0/ports'
        req.headers = self.headers
        req.body = port_req.to_json
      end

      raise Exceptions::OSApiException.new("create new port on #{net_id} for #{vm_name} failed, error code: #{response.status}") if response.status != 201

      json(response.body)[:port][:id]
    end

    # Rest call to openstack for add new floatingip to a ip port
    #
    # @param port_uuid [String] the private ip port where the floatingip must be bind
    # @raise Exceptions::OSApiException if error occurs
    # No return
    def add_floating_ip(port_uuid)
      floating_req = {
                       floatingip: { floating_network_id: @nets[:public], port_id: port_uuid }
                     }


      response = @conn[:neutron].post do |req|
        req.url "/v2.0/floatingips"
        req.headers = self.headers
        req.body = floating_req.to_json
      end

      raise Exceptions::OSApiException.new("add floatingip (on #{port_uuid}) failed, error code: #{response.status}") if response.status != 201
    end

    # Rest call to openstack for delete an ip port
    #
    # @param port_uuid [String] the private ip port identifier
    # @raise Exceptions::OSApiException if error occurs
    # No return
    def delete_port(port_uuid)
      response = @conn[:neutron].delete do |req|
        req.url "/v2.0/ports/#{port_uuid}"
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("Delete Api request failed on /v2.0/ports/#{port_uuid}: #{response.status}") if response.status != 204
    end

    # Rest call to openstack for delete an floatingip
    #
    # @param floatingip_id [String] the floatingip identifier
    # @raise Exceptions::OSApiException if error occurs
    # No return
    def delete_floatingip(floatingip_id)
      response = @conn[:nova].delete do |req|
        req.url "/v2/#{@tenant}/os-floating-ips/#{floatingip_id}"
        req.headers = self.headers
      end

      raise Exceptions::OSApiException.new("Delete request on /v2.0/floatingips/#{floatingip_id}: #{response.status}") if response.status != 202
    end

    # Helper function for parse json call
    #
    # @param body [String] the json on input
    # @return [Hash] the json hashed with symbol for indexes
    def json(body)
      JSON.parse(body, symbolize_names: true)
    end

  end
end
