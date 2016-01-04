# NextDeploy

[![Build Status](http://build.nextdeploy.io/buildStatus/icon?job=nextdeploy)](http://build.nextdeploy.io/job/nextdeploy/)

The project is an ongoing deployment system virtualized development environment in the cloud. Generic installation templates are defined for different frameworks or cms. When creating a project, a git repository is associated with this installation template. Thus, virtual machines can be run on demand by deploying the site on a preinstalled system following prerequisites specified in the template.

The project uses a cloud to host vms. The api is working actually with openstack. In the future, HP and AWS cloud will also be taken into account. Installation templates are defined for the puppet tool. Git is used for versioning developments on projects and Gitlab manager is installed for these deposits. A REST API (in ruby on rails) is the intermediary between these systems and can manage user authentication, project creation, adding users, and of course the launch of vms.

The REST api can be reached with 3 different ways
* a local client (ruby script) to be use with commandline (Repository here: https://github.com/ricofehr/nextdeploy-cli)
* an WebUI developped with EMBER (Repository here: https://github.com/ricofehr/nextdeploy-webui)
* an android application (Repository here: https://github.com/ricofehr/nextdeploy-android)

## Features

* Vm creations on the fly
* Actually, 3 cms are supporting: drupal, wordpress and symfony2
* Gitlab for hosting repository
* Rest api developped with rails
* a WebUI, a bash command and an android application for transmit with rest api
* Based on vagrant, there is a complete process for install the project on his laptop.
* Working progress, more features in future (more cms and technos supported, ldap connector for authentification, lot of linux image, HP cloud connector, ...)

## Folders

* /client The Ruby client for exchange with the rest api thanks to commandline ([submodule](https://github.com/ricofehr/nextdeploy-cli))
* /out Some logs, specially during the setup of the platform
* /puppet Installation templates for the vms into the cloud. Customs class are included into puppet/pm folder, others are taken from puppetforge catalog. ([submodule](https://github.com/ricofehr/nextdeploy-puppet))
* /ror The rails application who serves the rest api. 
* /ror/public The Webui developped on EmberJs ([submodule](https://github.com/ricofehr/nextdeploy-webui))
* /scripts Some jobs for setup completely the project in local workstation or remote servers
* /tmp Temporary folder
* /vagrant Definitions for create the 4 openstack nodes, the manager node and the monitoring node

## Submodules and Clone
The cli application (client folder), the webui (ror/public folder), the vm installation templates (/puppet folder) and some puppet modules of the community used by installation and setting of nextdeploy, are included in the project in the form of Submodules git.

To retrieve, use this clone cmd.
```
git clone --recursive git@github.com:ricofehr/nextdeploy
```

If the clone has already been done, execute this command.
```
git submodule update --init --recursive
```

## Local Installation

For the installation of the project on the computer for testing or development
```
./scripts/./setup
```
Some extra options are available with this command
```
Usage: ./scripts/./setup [options]

-h           this is some help text.
-c           no destroy vm already created
-q           quieter mode
-y           ask yes to all question
-fs xxxx     fileshare strategy for rails app source between host and nextdeploy node, nfs/rsync (Default is nfs for libvirt and virtualbox for vbox)
-cu xxxx     cli username (default is usera@os.nextdeploy)
-cp xxxx     cli password (default is word123123)
-g xxxx      gitlaburi (default is gitlab.nextdeploy.local)
-hv xxxx     hypervisor: virtualbox or libvirt (default is virtualbox)
-nv          enable nested virtualisation for nova (default is off), EXPERIMENTAL
-ne xxxx     set the neutron external interface (for the public openstack subnet, default is eth2)
-np xxxx     set the neutron public interface (default is eth0)
-p xxxx      subnet prefix (external network) for vms (default is 192.168.171)
-a xxxx      subnet prefix for api network (default is 192.168.170)
-d xxxx      subnet prefix for data network (default is 172.16.171)
-e xxxx      subnet prefix for management network (default is 172.16.170)
-n xxxx      dns server for vms (default is 192.168.171.60)
-m xxxx      nextdeploy webui URI (default is nextdeploy.local)
-mc xxxx     ndc2 default URI (default is ndc2.local)
-ma xxxx     an email for some alerts purpose (default is admin@example.com)
-pa xxxx     admin password used for some webui (like grafana)
-s xxxx      nextdeploy dns suffixes (default is os.nextdeploy)
-r           avoid change resolv.conf and hosts files
-vm          start a vm after build is complete
```
Installation requires a large amount of RAM, a computer with 12GB of RAM minimum is required. Indeed, the OpenStack cloud is then implemented using vagrant through the creation of four virtual machines (controller, neutron, glance, nova) and another virtual machine is created to launch the rest app and hosts the gitlab and templates puppet installation. The script requires "curl" and "sudo" as a prerequisite.

The setup script has been tested on mac os x, debian, ubuntu and fedora. The hypervisor for nextdeploy installation is virtualbox (mac osx) or kvm (debian, ubuntu, fedora). Knowing that the performance of virtual machines deployed on OpenStack will be better if nextdeploy is virtualized through kvm.

A set of groups, users and projects are created during installation.

## Remote installation

For a remote installation, you must have at least 6 physical machines availables: 4 for the cloud, 1 for nextdeploy manager and 1 for the monitoring node. From this set, the following script makes much of the installation work and configuration based on puppet templates associated with vms vagrant.
```
Usage: ./scripts/./setup-remote [options]

-h                          this is some help text.
-q                          quieter mode
-y                          non-interactive mode, take default value when no setted
-g xxxx                     gitlaburi (default is gitlab.domain)
-ne xxxx                    set the neutron external interface (for the public openstack subnet, default is eth1)
-np xxxx                    set the neutron public interface (default is eth0)
-p xxxx                     subnet prefix (external network) for vms (default is 192.168.171)
-a xxxx                     subnet prefix for api network (default is 192.168.170)
-d xxxx                     subnet prefix for data network (default is 172.16.171)
-e xxxx                     subnet prefix for management network (default is 172.16.170)
-n xxxx                     dns server for vms (default is 192.168.171.60)
-m xxxx                     nextdeploy global URI (default is nextdeploy.domain)
-ma xxxx                    an email for some alerts purpose (default is admin@example.com)
-pa xxxx                    admin password used for some webui (like grafana)
-s xxxx                     nextdeploy dns suffixes (default is os.domain)
-t xxxx                     set the time needed to reboot a node (default is 220)
--domain xxxx               global domain for the nextdeploy nodes (default is none)
--puppetmaster-ip   xxxx    ip for puppetmaster service
--puppetmaster-sshport xxxx port for ssh to puppermaster node (default is 22)
--puppetmaster-fqdn xxxx    fqdn for puppetmaster service
--install-puppetmaster      install the puppet master service
--update-puppetmaster       update the puppet master service with lastest modules and hiera files
--controller-ip xxxx        install the controller node (ip needed)
--neutron-ip xxxx           install the neutron node (ip needed)
--glance-ip xxxx            install the glance node (ip needed)
--nova-ip xxxx              install the nova node (ip needed)
--nova2-ip xxxx             install a second nova node (ip needed)
--nova3-ip xxxx             install a third nova node (ip needed)
--nova4-ip xxxx             install a fourth nova node (ip needed)
--nova5-ip xxxx             install a fifth nova node (ip needed)
--nextdeploy-ip xxxx        install the nextdeploy manager node (ip needed)
--ndc2-ip xxxx              install the ndc2 node (ip needed)
```

## Groupes / Users

5 groups are defined at nextdeploy:
* Admin: all rights
* Lead Dev: all rights to the projects associated with it
* Dev: only rights to edit their profile, access to the git repository, launch vms and ssh on them.
* Pm: Only rights to edit their profile or launch vms
* Guest: Only rights to recover access to urls vms

When local nextdeploy facility (see above Local Installation), the following users are created:
* usera@os.nextdeploy (password: word123123 and admin group)
* userl@os.nextdeploy (password: word123123 and lead dev group)
* userd@os.nextdeploy (password: word123123 and dev group)
* userp@os.nextdeploy (password: word123123 and pm group)
* userg@os.nextdeploy (password: word123123 and guest group)


## Vm installation pattern

The tool used for managing templates facilities associated with the project is puppet. Currently supported technologies are mainly directed php with Symfony2, drupal and wordpress. It is also possible to start a vm "php" without involving a framework or cms. To follow, support for Java technology (ame), windows (sitecore), ...

The git repository for this templates: https://github.com/ricofehr/nextdeploy-puppet

## Android Application

The android application is on a separate repository.
Go here: http://github.com/ricofehr/nextdeploy-android


## REST API

The API is the scheduler and project facilitator. Developed in rails, the api manages user authentication, maintains nextdeploy data model and interfaces with apis of gitlab and cloud (OpenStack at this time). Puma rails server is launched to handle requests.
Thus, we will find the following calls:
```
                         Prefix Verb   URI Pattern
            api_v1_user_current GET    /api/v1/user
           api_v1_group_current GET    /api/v1/group
                  api_v1_groups GET    /api/v1/groups
                                POST   /api/v1/groups
                   api_v1_group GET    /api/v1/groups/:id
                                PATCH  /api/v1/groups/:id
                                PUT    /api/v1/groups/:id
                                DELETE /api/v1/groups/:id
                  api_v1_brands GET    /api/v1/brands
                                POST   /api/v1/brands
                   api_v1_brand GET    /api/v1/brands/:id
                                PATCH  /api/v1/brands/:id
                                PUT    /api/v1/brands/:id
                                DELETE /api/v1/brands/:id
                api_v1_projects GET    /api/v1/projects
                                POST   /api/v1/projects
                 api_v1_project GET    /api/v1/projects/:id
                                PATCH  /api/v1/projects/:id
                                PUT    /api/v1/projects/:id
                                DELETE /api/v1/projects/:id
                     api_v1_vms GET    /api/v1/vms
                                POST   /api/v1/vms
                      api_v1_vm GET    /api/v1/vms/:id
                                PATCH  /api/v1/vms/:id
                                PUT    /api/v1/vms/:id
                                DELETE /api/v1/vms/:id
                 api_v1_sshkeys GET    /api/v1/sshkeys
                                POST   /api/v1/sshkeys
                  api_v1_sshkey GET    /api/v1/sshkeys/:id
                                PATCH  /api/v1/sshkeys/:id
                                PUT    /api/v1/sshkeys/:id
                                DELETE /api/v1/sshkeys/:id
                   api_v1_users GET    /api/v1/users
                                POST   /api/v1/users
                                GET    /api/v1/users/:id
                                PATCH  /api/v1/users/:id
                                PUT    /api/v1/users/:id
                                DELETE /api/v1/users/:id
                api_v1_branches GET    /api/v1/branches
                  api_v1_branch GET    /api/v1/branches/:id
                 api_v1_commits GET    /api/v1/commits
                  api_v1_commit GET    /api/v1/commits/:id
                 api_v1_technos GET    /api/v1/technos
                  api_v1_techno GET    /api/v1/technos/:id
                 api_v1_flavors GET    /api/v1/flavors
                  api_v1_flavor GET    /api/v1/flavors/:id
              api_v1_frameworks GET    /api/v1/frameworks
               api_v1_framework GET    /api/v1/frameworks/:id
            api_v1_systemimages GET    /api/v1/systemimages
             api_v1_systemimage GET    /api/v1/systemimages/:id
        new_api_v1_user_session GET    /api/v1/users/sign_in
            api_v1_user_session POST   /api/v1/users/sign_in
    destroy_api_v1_user_session DELETE /api/v1/users/sign_out
           api_v1_user_password POST   /api/v1/users/password
       new_api_v1_user_password GET    /api/v1/users/password/new
      edit_api_v1_user_password GET    /api/v1/users/password/edit
                                PATCH  /api/v1/users/password
                                PUT    /api/v1/users/password
cancel_api_v1_user_registration GET    /api/v1/users/cancel
       api_v1_user_registration POST   /api/v1/users
   new_api_v1_user_registration GET    /api/v1/users/sign_up
  edit_api_v1_user_registration GET    /api/v1/users/edit
                                PATCH  /api/v1/users
                                PUT    /api/v1/users
                                DELETE /api/v1/users
```


## CommandLine Client

A client developed in Ruby allows communication with the rest api via the command line.
A small configuration file is related to the script and must contain the email / password of the user.
An example of /etc/nextdeploy.conf
```
email: userl@os.nextdeploy
password: word123123
endpoint: nextdeploy.local
```

The ruby client manages the following commands
```
`  ndeploy clone [projectname]                         # clone project in current folder
`  ndeploy config [endpoint] [username] [password]     # get/set properties settings for nextdeploy
`  ndeploy destroy                                     # destroy current vm
`  ndeploy getftp assets|dump [project]                # get an assets archive or a dump for the [project]
`  ndeploy git [cmd]                                   # Executes a git command
`  ndeploy help [COMMAND]                              # Describe available commands or one specific command
`  ndeploy launch [projectname] [branch] [commit]      # launch [commit] (default is head) on the [branch] (default is master) for [projectname] into remote nextdeploy platform
`  ndeploy list                                        # list launched vms for current user
`  ndeploy listftp assets|dump [project]               # list assets archive or a dump for the [project]
`  ndeploy projects                                    # list projects for current user
`  ndeploy putftp assets|dump [project] [file]         # putftp an assets archive [file] or a dump [file] for the [project]
`  ndeploy ssh                                         # ssh into remote vm
`  ndeploy sshkey                                      # Put your public ssh key (id_rsa.pub) onto NextDeploy
`  ndeploy sshkeys                                     # List sshkeys actually associated to the current user
`  ndeploy up                                          # launch current commit to remote nextdeploy
`  ndeploy upgrade                                     # upgrade ndeploy with the last version
`  ndeploy version                                     # print current version of ndeploy
```

The git repository for cli application: https://github.com/ricofehr/nextdeploy-cli


## Ember

The Web Gui is developed with Ember framework.
The Ember stack is localised in rails standard location, into public folder.
From this publics folder, we find MVC classes respectively into models / templates / controllers folders.
For generate application.js
```
cd ror/public && ./bin/./ember_build
```

The git repository for webui application: https://github.com/ricofehr/nextdeploy-webui

## Yard

```
cd ror && yardoc lib/**/*.rb app/**/*.rb config/**/*.rb
```


## TODOS

* More installation templates
* More operating systems
* Allow a connection to an external ldap for authentication
* A connector for AWS or HP Cloud.
* Unit tests
* Improving the quality of code, rewrite some "ugly" blocks
* Improve the logging task for rest api
* Add elements of monitoring and supervision
* Improve usability of the UI
* Implement some extra functionnalities for the vms: security test, code quality parser, ..


## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.
