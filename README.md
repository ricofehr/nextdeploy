# Mvmc

[![Build Status](http://mvmc.publicis-modem.fr:9292/buildStatus/icon?job=mvmc)](http://mvmc.publicis-modem.fr:9292/job/mvmc/)

The project is an ongoing deployment system virtualized development environment in the cloud. Generic installation templates are defined for different frameworks or cms. When creating a project, a git repository is associated with this installation template. Thus, virtual machines can be run on demand by deploying the site on a preinstalled system following prerequisites specified in the template.

The project uses a cloud to host vms. The api is working actually with openstack. In the future, HP and AWS cloud will also be taken into account. Installation templates are defined for the puppet tool. Git is used for versioning developments on projects and Gitlab manager is installed for these deposits. A REST API (in ruby on rails) is the intermediary between these systems and can manage user authentication, project creation, adding users, and of course the launch of vms.

The REST api can be reached with 3 different ways
* a local client (ruby script) to be use with commandline (Repository here: https://github.com/ricofehr/mvmc-cli)
* an WebUI developped with EMBER (Repository here: https://github.com/ricofehr/mvmc-webui)
* an android application (Repository here: https://github.com/ricofehr/mvmc-android)

## Features

* Vm creations on the fly
* Actually, 3 cms are supporting: drupal, wordpress and symfony2
* Gitlab for hosting repository
* Rest api developped with rails
* a WebUI, a bash command and an android application for transmit with rest api
* Based on vagrant, there is a complete process for install the project on his laptop.
* Working progress, more features in future (more cms and technos supported, ldap connector for authentification, lot of linux image, HP cloud connector, ...)

## Folders

* /client The Ruby client for exchange with the rest api thanks to commandline
* /out Some logs, specially during the setup of the platform
* /puppet Installation templates for the vms into the cloud. Customs class are included into puppet/pm folder, others are taken from puppetforge catalog.
* /ror The rails application who serves the rest api. The Webui developped on EmberJs is included into /ror/public folder.
* /scripts Some jobs for setup completely the project in local workstation, start or stop mvmc
* /tmp Temporary folder
* /vagrant Definitions for create the 4 openstack nodes and the manager node

## Submodules and Clone
The cli application (client folder) and the puppet modules of the community are included in the project in the form of Submodules git.

To retrieve, use this clone cmd.
```
git clone --recursive git@github.com:ricofehr/mvmc
```

If the clone has already been done, execute this command.
```
git submodule update --init
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
-y           ask yes to all questions
-g xxxx      gitlaburi (default is gitlab.local)
-hv          hypervisor: vbox or kvm (default is vbox)
-p xxxx      subnet prefix for vms (default is 192.168.171)
-n xxxx      dns server for vms (default is 192.168.171.60)
-m xxxx      mvmc webui URI (default is mvmc.local)
-s xxxx      mvmc dns suffixes (default is os.mvmc)
-r           avoid change resolv.conf file
```
Installation requires a large amount of RAM, a computer with 8GB of RAM minimum is required. Indeed, the OpenStack cloud is then implemented using vagrant through the creation of four virtual machines (controller, neutron, glance, nova) and another virtual machine is created to launch the rest app and hosts the gitlab and templates puppet installation. The script requires "curl" and "sudo" as a prerequisite.

The setup script has been tested on mac os x, debian, ubuntu and fedora. The hypervisor for mvmc installation is virtualbox (mac osx) or kvm (debian, ubuntu, fedora). Knowing that the performance of virtual machines deployed on OpenStack will be much better if mvmc is virtualized through kvm. Indeed, kvm can then itself be used as a hypervisor-level cloud. Otherwise (mvmc installation on virtualbox on macosx), it uses qemu.

A set of groups, users and projects are created during installation.

## Remote installation

For a remote installation, you must have 5 physical machines availabes: 4 for the cloud and 1 for mvmc manager. From this set, the following script makes much of the installation work and configuration based on puppet templates associated with vms vagrant.
```
./scripts/./setup-remote
```

## Groupes / Users

5 groups are defined at mvmc:
* Admin: all rights
* Lead Dev: all rights to the projects associated with it
* Dev: only rights to edit their profile, access to the git repository, launch vms and ssh on them.
* Pm: Only rights to edit their profile or launch vms
* Guest: Only rights to recover access to urls vms

When local mvmc facility (see above INSTALL), the following users are created:
* usera@os.mvmc (password: word123123 and admin group)
* userl@os.mvmc (password: word123123 and lead dev group)
* userd@os.mvmc (password: word123123 and dev group)
* userp@os.mvmc (password: word123123 and pm group)
* userg@os.mvmc (password: word123123 and guest group)


## Vm installation pattern

The tool used for managing templates facilities associated with the project is puppet. Currently supported technologies are mainly directed php with Symfony2, drupal and wordpress. It is also possible to start a vm "php" without involving a framework or cms. To follow, support for Java technology (ame), windows (sitecore), ...

## Android Application

The android application is on a separate repository.
Go here: http://github.com/ricofehr/mvmc-android


## REST API

The API is the scheduler and project facilitator. Developed in rails, the api manages user authentication, maintains mvmc data model and interfaces with apis of gitlab and cloud (OpenStack at this time). Puma rails server is launched to handle requests.
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
An example of /etc/mvmc.conf
```
email: userl@os.mvmc
password: word123123
endpoint: mvmc.local
```

The ruby client manages the following commands
```
`mvmc help` will print help about this command
`mvmc up` launch current commit into vm
`mvmc destroy` destroy current vm associated to this project
`mvmc ssh` ssh into current vm
`mvmc projects` list projects for current user
```

The git repository for cli application: https://github.com/ricofehr/mvmc-cli


## Ember

The Web Gui is developed with Ember framework.
The Ember stack is localised in rails standard location, into public folder.
From this publics folder, we find MVC classes respectively into models / templates / controllers folders.
For generate application.js
```
cd ror/public && ./bin/./ember_build
```

The git repository for webui application: https://github.com/ricofehr/mvmc-webui

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
