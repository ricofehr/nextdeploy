#Flush all tables
Framework.destroy_all
puts "destroy framework"
Techno.destroy_all
puts "destroy techno"
Brand.destroy_all
puts "destroy brand"
Project.destroy_all
puts "destroy projects"
User.destroy_all
puts "destroy users"
Group.destroy_all
puts "destroy groups"
Systemimagetype.destroy_all
puts "destroy systemimages"
Vmsize.destroy_all
puts "destroy flavors"
#flavor import rows
flavor_tiny = Vmsize.create!(title: 'm1.tiny', description: '1cpu/512M/15G')
flavor_small = Vmsize.create!(title: 'm1.small', description: '2cpu/1024M/15G')
flavor_medium = Vmsize.create!(title: 'm1.medium', description: '2cpu/4096M/40G')
flavor_large = Vmsize.create!(title: 'm1.large', description: '4cpu/8192M/80G')

#Framework import rows
framework_sf2 = Framework.create!(
                  name: 'Symfony2',
                  publicfolder: 'web/',
                  rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /app_dev.php [L]\\nRewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\nRewriteRule .* /app_dev.php [L]\\n",
                  puppetclass: 'pm::deploy::symfony2'
                )

framework_sf3 = Framework.create!(
                  name: 'Symfony3',
                  publicfolder: 'web/',
                  rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /app_dev.php [L]\\nRewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\nRewriteRule .* /app_dev.php [L]\\n",
                  puppetclass: 'pm::deploy::symfony3'
                )

framework_drupal = Framework.create!(
                     name: 'Drupal7',
                     publicfolder: '',
                     rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /index.php [L]\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\nRewriteCond %%{literal('%')}{REQUEST_URI} !=/favicon.ico\\nRewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\nRewriteRule ^ index.php [L]\\n",
                     puppetclass: 'pm::deploy::drupal'
                   )

framework_drupal8 = Framework.create!(
                      name: 'Drupal8',
                      publicfolder: '',
                      rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /index.php [L]\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\nRewriteCond %%{literal('%')}{REQUEST_URI} !=/favicon.ico\\nRewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\nRewriteRule ^ index.php [L]\\n",
                      puppetclass: 'pm::deploy::drupal'
                    )

framework_wordpress = Framework.create!(
                        name: 'Wordpress',
                        publicfolder: '',
                        rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /index.php [L]\\nRewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\nRewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\nRewriteRule .* /index.php [L]\\n",
                        puppetclass: 'pm::deploy::wordpress'
                      )

framework_no = Framework.create(
                 name: 'Static',
                 publicfolder: '',
                 rewrites: '',
                 puppetclass: 'pm::deploy::static'
               )

puts "Created #{Framework.count} frameworks"

#Techno import rows
techno_apache = Techno.create!(
                  name: "apache",
                  puppetclass: "pm::http",
                  ordering: 160,
                  hiera: "docroot: %{docroot}
apache_vhost:
  %{vhost}:
    vhost_name: '*'
    port: %{portA}
    override:
      - 'All'
    options:
      - 'Indexes'
      - 'FollowSymLinks'
    aliases:
      - alias: '/_html/'
        path: '/var/www/%{projectname}/html/'
      - alias: '/pm_tools/'
        path: '/var/www/pm_tools/'
      - alias: '/robots.txt'
        path: '/var/www/robots.txt'
      - alias: '/status_ok'
        path: '/var/www/status_ok'
    ensure: present
    docroot_owner: 'modem'
    docroot_group: 'www-data'
    docroot: %{docroot}
    directories:
      - path: '/var/www/%{projectname}/html/'
        options:
          - 'Indexes'
          - 'FollowSymLinks'
      - path: /var/www/pm_tools
        allow_override:
        - 'All'
      - path: %{docroot}
        allow_override:
        - 'All'
        custom_fragment: \"%{rewrites}\""
            )

techno_mongodb = Techno.create!(
                   name: "mongodb-2.6",
                   puppetclass: "pm::nosql::mongo",
                   ordering: 80,
                   hiera: "ismongo: 1
mongodb::globals::version: '2.6'"
                 )

techno_rabbitmq = Techno.create!(
                    name: "rabbitmq",
                    puppetclass: "pm::rabbit",
                    ordering: 60,
                    hiera: ""
                  )

techno_elasticsearch = Techno.create!(
                         name: "elasticsearch",
                         puppetclass: "pm::elastic",
                         ordering: 40,
                         hiera: ""
                       )

techno_memcached = Techno.create!(
                     name: "memcached",
                     puppetclass: "pm::nosql::memcache",
                     ordering: 100,
                     hiera: "iscache: 1"
                   )

techno_redis = Techno.create!(
                 name: "redis",
                 puppetclass: "pm::nosql::redis",
                 ordering: 80,
                 hiera: ""
               )

techno_varnish = Techno.create!(
                   name: "varnish",
                   puppetclass: "pm::varnish",
                   ordering: 200,
                   hiera: ""
                 )

techno_mysql = Techno.create!(
                 name: "mysql",
                 puppetclass: "pm::sql",
                 ordering: 70,
                 hiera: "ismysql: 1
mysql_db:
  s_bdd:
    user: s_bdd
    password: s_bdd
    host: 'localhost'
    grant: 'all'"
               )

techno_nodejs = Techno.create!(
                  name: "nodejs",
                  puppetclass: "pm::nodejs",
                  ordering: 140,
                  hiera: ""
                )

techno_mongodb3 = Techno.create!(
                    name: "mongodb-3.0",
                    puppetclass: "pm::nosql::mongo",
                    ordering: 80,
                    hiera: "ismongo: 1
mongodb::globals::version: '3.0'"
                  )

techno_mongodb32 = Techno.create!(
                     name: "mongodb-3.2",
                     puppetclass: "pm::nosql::mongo",
                     ordering: 80,
                     hiera: "ismongo: 1
mongodb::globals::version: '3.2'"
                   )

puts "Created #{Techno.count} technos"

#Brand import rows
brand_cust1 = Brand.create!(name: "Test Company")
brand_cust2 = Brand.create!(name: "YourCompany")
brand_cust3 = Brand.create!(name: "HisCompany")

puts "Created #{Brand.count} brands"

linux = Systemimagetype.create!(name: 'linux')

puts "Create #{Systemimagetype.count} system image types"

admin_g = Group.create!(name: 'Admin', access_level: 50)
lead_g = Group.create!(name: 'Project Lead', access_level: 40)
dev_g = Group.create!(name: 'Developer', access_level: 30)
pm_g = Group.create!(name: 'Project Manager', access_level: 20)
guest_g = Group.create!(name: 'Guest', access_level: 10)
puts "Created #{Group.count} groups"

admin = User.create!(
          email: 'usera@os.nextdeploy',
          firstname: 'usera',
          lastname: 'usera',
          company: 'My Company',
          is_project_create: true,
          quotavm: 0,
          password: 'word123123',
          password_confirmation: 'word123123',
          group: admin_g
        )

user_lead = User.create!(
              email: 'userl@os.nextdeploy',
              firstname: 'userl',
              lastname: 'userl',
              company: 'My Company',
              is_project_create: true,
              quotavm: 10,
              password: 'word123123',
              password_confirmation: 'word123123',
              group: lead_g
            )

user_dev = User.create!(
             email: 'userd@os.nextdeploy',
             firstname: 'userd',
             lastname: 'userd',
             company: 'My Company',
             is_project_create: false,
             quotavm: 5,
             password: 'word123123',
             password_confirmation: 'word123123',
             group: dev_g
           )

user_pm = User.create!(
            email: 'userp@os.nextdeploy',
            firstname: 'userp',
            lastname: 'userp',
            company: 'My Company',
            is_project_create: false,
            quotavm: 5,
            password: 'word123123',
            password_confirmation: 'word123123',
            group: pm_g
          )

user_g = User.create!(
           email: 'userg@os.nextdeploy',
           firstname: 'userg',
           lastname: 'userg',
           company: 'My Company',
           is_project_create: false,
           quotavm: 3,
           password: 'word123123',
           password_confirmation: 'word123123',
           group: guest_g
         )

puts "Created #{User.count} users"


#Project import rows
project_drupal = Project.create!(
                   name: "www.drupalmycompany.com",
                   brand: brand_cust1,
                   framework: framework_drupal,
                   gitpath: "mycompany-www-drupalmycompany-com",
                   systemimagetype: linux,
                   enabled: true,
                   login: "modem",
                   password: "modem",
                   owner: admin,
                   vmsizes: [flavor_tiny, flavor_small],
                   users: [admin, user_lead, user_dev, user_pm, user_g],
                   technos: [
                     techno_varnish,
                     techno_apache,
                     techno_mysql,
                     techno_redis,
                     techno_memcached
                   ]
                 )

project_symfony_c = Project.create!(
                      name: "www.symfonyyourcompany.com",
                      systemimagetype: linux,
                      brand: brand_cust2,
                      framework: framework_sf2,
                      login: "modem",
                      password: "modem",
                      owner: admin,
                      vmsizes: [flavor_tiny, flavor_small],
                      gitpath: "yourcompany-www-symfonyyourcompany-com",
                      enabled: true,
                      users: [admin, user_dev, user_g],
                      technos: [
                        techno_varnish,
                        techno_apache,
                        techno_mongodb,
                        techno_redis,
                        techno_rabbitmq,
                        techno_elasticsearch
                      ]
                    )

project_symfony_s = Project.create!(
                      name: "www.symfonyhiscompany.com",
                      systemimagetype: linux,
                      brand: brand_cust3,
                      framework: framework_sf2,
                      login: "modem",
                      password: "modem",
                      owner: admin,
                      vmsizes: [flavor_tiny],
                      gitpath: "hiscompany-www-symfonyhiscompany-com",
                      enabled: true,
                      users: [admin, user_dev],
                      technos: [
                        techno_varnish,
                        techno_apache,
                        techno_mysql,
                        techno_redis
                      ]
                    )

project_no = Project.create!(
               name: "www.statichiscompany.com",
               systemimagetype: linux,
               brand: brand_cust3,
               framework: framework_no,
               login: "modem",
               password: "modem",
               owner: admin,
               vmsizes: [flavor_tiny],
               users: [admin, user_lead, user_dev],
               gitpath: "hiscompany-www-statichiscompany-com",
               enabled: true,
               technos: [techno_varnish, techno_apache]
             )

project_wordpress = Project.create!(
                      name: "www.wordpressmycompany.com",
                      systemimagetype: linux,
                      brand: brand_cust1,
                      framework: framework_wordpress,
                      login: "modem",
                      password: "modem",
                      owner: admin,
                      vmsizes: [flavor_tiny, flavor_small],
                      users: [admin, user_lead, user_g],
                      gitpath: "mycompany-www-wordpressmycompany-com",
                      enabled: true,
                      technos: [techno_varnish, techno_apache, techno_mysql]
                    )

project_njs = Project.create!(
                name: "www.njsyourcompany.com",
                systemimagetype: linux,
                brand: brand_cust2,
                framework: framework_no,
                login: "modem",
                password: "modem",
                owner: admin,
                vmsizes: [flavor_tiny],
                users: [admin, user_lead, user_dev],
                gitpath: "yourcompany-www-njsyourcompany-com",
                enabled: true,
                technos: [techno_varnish, techno_apache, techno_nodejs]
              )


puts "Created #{Project.count} projects"



# HACK: Oups, it's ugly. Commands to get glance_id generated just before during glance installation
glance_id_j = %x(glance --os-username user --os-password wordpass --os-tenant-name tenant0 --os-auth-url http://controller-m:35357/v2.0 image-show osvm-jessie | grep "id" | sed "s; [^ ]*$;;" | sed "s;^.* ;;")
glance_id_j.strip!

glance_id_t = %x(glance --os-username user --os-password wordpass --os-tenant-name tenant0 --os-auth-url http://controller-m:35357/v2.0 image-show osvm-trusty | grep "id" | sed "s; [^ ]*$;;" | sed "s;^.* ;;")
glance_id_t.strip!

ubuntu14 = Systemimage.create!(
             name: 'Ubuntu1404',
             glance_id: glance_id_t,
             enabled: true,
             systemimagetype: linux
           )

debian8 = Systemimage.create!(
            name: 'Debian8',
            glance_id: glance_id_j,
            enabled: true,
            systemimagetype: linux
          )

puts "Create #{Systemimage.count} system image"
