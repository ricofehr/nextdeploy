# NextDeploy

[![Build Status](http://build.nextdeploy.io/buildStatus/icon?job=nextdeploy)](http://build.nextdeploy.io/job/nextdeploy/)

NextDeploy is a deployment system of virtualized web environments (development or production) in a compute cloud. Generic installation templates are defined for different frameworks or cms. When creating a project, a git repository is associated with this installation template. Thus, virtual machines can be run on demand by deploying the site on a preinstalled system following prerequisites specified.

[![NextDeploy](https://img.youtube.com/vi/Qu4xTetmpjs/0.jpg)](https://www.youtube.com/watch?v=Qu4xTetmpjs)

NextDeploy uses an openstack cloud to host vms. In future, AWS and GCE public cloud will also be taken into account. Installation templates are defined with Puppet. Git is used for versioning developments on projects and Gitlab manager is installed for these deposits. A REST API (in ruby on rails) is the intermediary between these systems and can manage user authentication, project creation, adding users, and of course the launch of vms.

The REST api can be reached with 3 different ways
* an WebUI developped with EMBER (Repository here: https://github.com/ricofehr/nextdeploy-webui)
* a CLI Software (Repository here: https://github.com/ricofehr/nextdeploy-cli)
* an android application (Repository here: https://github.com/ricofehr/nextdeploy-android)


## Features

* Vms created into a private openstack cloud
* Actually, 3 cms are supporting: drupal, wordpress and symfony
* Support for nodejs projects
* Gitlab for versioning repository
* Continuous Integration on user projects: sonar scan, documentation, unit tests, security scans, ...
* Monitoring (with grafana) and supervise (with ansible) for each vm
* A WebUI, a CLI software and an android application
* Docker integration (thanks to CLI software) for launching user's projects in laptop
* Based on vagrant, there is a complete process for install NextDeploy on his workstation for contributing.
* Working progress, more features in future (more cms and technos supported, Aws connector, ...)


## Repository Structure
```
nextdeploy/
+--client/      The Ruby client for exchange with the rest api thanks to commandline (submodule, https://github.com/ricofehr/nextdeploy-cli)
+--out/         Some logs, specially during the setup of the platform
+--puppet/      Installation templates for the vms into the cloud. (submodule, https://github.com/ricofehr/nextdeploy-puppet)
   +---pm/      Customs puppet classes
+--ror/         The rails application who serves the rest api
   +---public/  Destination folder for the EmberJs build of the webui app
   +---doc/     Destination folder for the yard code documentation
+--scripts/     Some jobs for setup completely the project in local workstation or remote servers
+--tmp/         Temporary folder
+--vagrant/     Definitions for create the 4 openstack nodes, the manager node and the monitoring node
+--webui/       The Webui developped on EmberJs (submodule, https://github.com/ricofehr/nextdeploy-webui)
```


## Submodules and Clone

The cli application (client folder), the webui (ror/public folder), the vm installation templates (puppet folder) are included in the project with the help of Submodules git.

To retrieve, use this clone cmd.
```
git clone --recursive git@github.com:ricofehr/nextdeploy
```

If the clone has already been done, execute this command.
```
git submodule update --init --recursive
```


## Local Installation

For test or contributing purpose, you can launch a complete installation of NextDeploy.
It will install an openstack cloud in local, so it's not relevant for an use in real life.
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
Installation requires a large amount of RAM, a computer with 16GB of RAM minimum is required. Indeed, the OpenStack cloud is then implemented using vagrant through the creation of four virtual machines (controller, neutron, glance, nova) and an other virtual machine is created: for launch the REST app, hosts the gitlab and templates puppet installation. The script requires "curl" and "sudo" as a prerequisite.

The setup script has been tested on mac os x, debian, ubuntu and fedora. The hypervisor for nextdeploy installation is virtualbox (mac osx) or kvm (debian, ubuntu, fedora). Knowing that the performance of virtual machines deployed on OpenStack will be better if nextdeploy is virtualized through kvm.

A set of groups, users and projects are created during installation.


## Remote installation

For a remote installation (for a real use), you must have at least 6 physical machines availables: 4 for the cloud, 1 for nextdeploy manager and 1 for the monitoring node. From this set, the following script makes much of the installation work and configuration based on puppet templates.
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


## Groups / Users

5 groups are defined at nextdeploy:
* Admin: all rights
* Project Lead: all rights to the projects associated with it, can add users and manage users on his projects
* Dev: only rights to edit their profile, access to the git repository, launch vms and ssh on them.
* Pm: only rights to edit their profile or launch vms
* Guest: only rights to recover access to urls vms

When local nextdeploy facility (see above Local Installation), the following users are created:
* usera@os.nextdeploy (password: word123123 and admin group)
* userl@os.nextdeploy (password: word123123 and lead dev group)
* userd@os.nextdeploy (password: word123123 and dev group)
* userp@os.nextdeploy (password: word123123 and pm group)
* userg@os.nextdeploy (password: word123123 and guest group)


## Vms installation

NextDeploy uses Puppet for managing installations of vms. Currently supported technologies are mainly php with Symfony2, drupal and wordpress. In next steps, support for Java technology (aem), ruby (ror), python (django), ...

The git repository for this templates: https://github.com/ricofehr/nextdeploy-puppet


## REST API

Developed in rails, the api manages user authentication, maintains nextdeploy data model and interfaces with gitlab and OpenStack. Puma rails server is launched to handle requests.

Yard manages the rails code documentation
```
cd ror && yardoc lib/**/*.rb app/**/*.rb config/**/*.rb lib/*.rb app/**/api/v1/*.rb
```
Updated code documentation http://doc.nextdeploy.io/api/code/


## Ember

The Web UI is developed with Ember framework.
The Ember stack is located in webui/ folder and builded in rails standard location, into public folder.
From this webui folder, we find MVC classes respectively into models / templates / controllers folders.
For build static app into ror/public (needs node, bower and ember-cli)
```
cd webui && ember build --output-path ../ror/public/
```

The git repository for webui application: https://github.com/ricofehr/nextdeploy-webui

Updated code documentation http://doc.nextdeploy.io/webui/code/


## CommandLine Client

A client developed in Ruby allows communication with the rest api via the command line.
For install this one, copy-paste this line in your teminal (OSX, Debian, Ubuntu or Fedora)
```
curl -sSL http://cli.nextdeploy.io/ | bash
```

A small configuration file is related to the script and must contain the email / password of the user.
An example of /etc/nextdeploy.conf
```
email: userl@os.nextdeploy
password: word123123
endpoint: api.nextdeploy.local
```

The ruby client manages the following commands
```
ndeploy clone [name]                                # clone project in current folder
ndeploy config [endpoint] [username] [password]     # get/set properties settings for nextdeploy
ndeploy destroy [idvm]                              # destroy a vm
ndeploy details [idvm]                              # Display some details for a vm
ndeploy docker                                      # [BETA] launch containers for execute current project
ndeploy folder [idvm] [workspace]                   # Share project folder from a vm
ndeploy getftp assets|dump|backup [project] [file]  # Get a file from project ftp
ndeploy help [COMMAND]                              # Describe available commands or one specific command
ndeploy launch [name] [branch]                      # Launch a new vm
ndeploy list [--all] [--head n]                     # list launched vms for current user.
ndeploy listftp assets|dump|backup [project]        # List files from project ftp
ndeploy logs [idvm]                                 # Display some logs for a vm
ndeploy projects                                    # list projects for current user
ndeploy putftp assets|dump [project] [file]         # Put a file onto project ftp
ndeploy ssh [idvm]                                  # ssh into a vm
ndeploy sshkey                                      # Put your public ssh key (id_rsa.pub) onto NextDeploy
ndeploy sshkeys                                     # List sshkeys actually associated to the current user
ndeploy up                                          # launch a new vm with current commit (in current folder)
ndeploy upgrade [--force]                           # upgrade ndeploy with the last version
ndeploy version                                     # print current version of ndeploy
```

The git repository for cli application: https://github.com/ricofehr/nextdeploy-cli


## Android Application

The android application is on a separate repository. But on a early stage of development.

Go here: http://github.com/ricofehr/nextdeploy-android


## TODO

* More installation templates
* More operating systems
* Connectors for public cloud: aws, gce, ...
* Connectors for external code repositories: bitbucket, github, ...

More details on the trello dashboard: https://trello.com/b/dVdgtJxE/nextdeploy


## Contributing

1. Fork it.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create new Pull Request.
