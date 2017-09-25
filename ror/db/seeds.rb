# Avoid overwrite used datas
exit if Vm.count != 0

# Flush all tables
Framework.destroy_all
puts "destroy framework"
Techno.destroy_all
puts "destroy techno"
Technotype.destroy_all
puts "destroy technoType"
Brand.destroy_all
puts "destroy brand"
Endpoint.destroy_all
puts "destroy endpoints"
Project.destroy_all
puts "destroy projects"
User.destroy_all
puts "destroy users"
Group.destroy_all
puts "destroy groups"
Systemimagetype.destroy_all
puts "destroy systemimages"
Vmsize.destroy_all
puts "destroy vmsizes"
Hpmessage.destroy_all
puts "destroy homepage posts"

# Vmsize import rows
flavor_tiny = Vmsize.create!(title: 'm1.tiny', description: '1cpu/512M/15G')
flavor_small = Vmsize.create!(title: 'm1.small', description: '2cpu/1024M/15G')
flavor_medium = Vmsize.create!(title: 'm1.medium', description: '2cpu/4096M/40G')
flavor_large = Vmsize.create!(title: 'm1.large', description: '4cpu/8192M/80G')

# Framework import rows
framework_sf2 =
  Framework.create!(
    name: 'Symfony2',
    publicfolder: 'web/',
    rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /app_dev.php [L]\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\n" +
              "RewriteRule .* /app_dev.php [L]\\n",
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/symfony
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:80
  volumes:
    - %%DOCROOT%%:/var/www/html
 '
  )

framework_sf3 =
  Framework.create!(
    name: 'Symfony3',
    publicfolder: 'web/',
    rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /app_dev.php [L]\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\n" +
              "RewriteRule .* /app_dev.php [L]\\n",
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/symfony
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:80
  volumes:
    - %%DOCROOT%%:/var/www/html
 '
  )

framework_drupal =
  Framework.create!(
    name: 'Drupal7',
    publicfolder: '',
    rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /index.php [L]\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_URI} !=/favicon.ico\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\n" +
              "RewriteRule ^ index.php [L]\\n",
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/drupal
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:80
  volumes:
    - %%DOCROOT%%:/var/www/html
'
  )

framework_drupal8 =
  Framework.create!(
    name: 'Drupal8',
    publicfolder: '',
    rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /index.php [L]\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_URI} !=/favicon.ico\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\n" +
              "RewriteRule ^ index.php [L]\\n",
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/drupal
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:80
  volumes:
    - %%DOCROOT%%:/var/www/html
'
  )

framework_wordpress =
  Framework.create!(
    name: 'Wordpress-4.8.2',
    publicfolder: '',
    rewrites: "RewriteEngine On\\nRewriteRule ^/?$ /index.php [L]\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_URI} !=/server-status\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-f\\n" +
              "RewriteCond %%{literal('%')}{REQUEST_FILENAME} !-d\\n" +
              "RewriteRule .* /index.php [L]\\n",
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/wordpress
  container_name: %%CONTAINERNAME%%
  environment:
    WORDPRESS_DB_HOST: \'mysql_%%PROJECTNAME%%\'
    WORDPRESS_DB_USER: \'root\'
    WORDPRESS_DB_PASSWORD: \'8to9or1\'
    WORDPRESS_DB_NAME: \'%%EPPATH%%\'
%%ENVVARS%%
  ports:
    - %%PORT%%:80
  volumes:
    - %%DOCROOT%%:/var/www/html
'
  )

framework_nodejs =
  Framework.create!(
    name: 'NodeJS',
    publicfolder: '',
    rewrites: '',
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/node
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:%%PORTEP%%
  volumes:
    - %%DOCROOT%%:/usr/src/app
  command: node app.js'
  )

framework_reactjs =
  Framework.create!(
    name: 'ReactJS',
    publicfolder: '',
    rewrites: '',
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/node
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:%%PORTEP%%
  volumes:
    - %%DOCROOT%%:/usr/src/app
  command: node bin/server.js'
  )

framework_no =
  Framework.create!(
    name: 'Static',
    publicfolder: '',
    rewrites: '',
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/webphp
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:80
  volumes:
    - %%DOCROOT%%:/var/www/html
'
  )

framework_basenurun =
  Framework.create!(
    name: 'BaseNurun',
    publicfolder: '',
    rewrites: "RewriteEngine On\\nRewriteCond %%{literal('%')}{REQUEST_URI} !(.*/inc/.*)\\n" +
              "RewriteRule ^(.*\\\\.php)$ includer.php?page=$1 [QSA]\\n",
    dockercompose: '%%CONTAINERNAME%%:
  image: nextdeploy/webphp
  container_name: %%CONTAINERNAME%%
%%ENVVARS%%
  ports:
    - %%PORT%%:80
  volumes:
    - %%DOCROOT%%:/var/www/html
'
  )

framework_noweb =
  Framework.create!(
    name: 'NoWeb',
    publicfolder: '',
    rewrites: ''
  )

puts "Created #{Framework.count} frameworks"

# Technotype import rows
cache = Technotype.create!(name: "Cache Server")
wserver = Technotype.create!(name: "Web Server")
bigdata = Technotype.create!(name: "Big Data")
bdd = Technotype.create!(name: "Database")
node = Technotype.create!(name: "Nodejs")
messaging = Technotype.create!(name: "Messaging")
keyvalue = Technotype.create!(name: "Keyvalue")
index = Technotype.create!(name: "Indexing")
java = Technotype.create!(name: "Java")
wkhtml = Technotype.create!(name: "Wkhtmltopdf")
apc = Technotype.create!(name: "Apc")
kibana = Technotype.create!(name: "Kibana")
imagick = Technotype.create!(name: "Imagemagick")

# Techno import rows
kibana4 =
  Techno.create!(
    name: "kibana4",
    ordering: 50,
    technotype: kibana,
    hiera: "",
    puppetclass: "pm::kibana",
    dockercompose: '%%CONTAINERNAME%%:
  image: kibana:4
  container_name: %%CONTAINERNAME%%',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Kibana
      shell: nmap 127.0.0.1 -p 5601 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

phpapc =
  Techno.create!(
    name: "php-apc",
    ordering: 170,
    technotype: apc,
    hiera: "",
    puppetclass: "pm::tool::phpapc",
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Apc
      shell: php -i | grep apc >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_wkhtml0123 =
  Techno.create!(
    name: "wkhtmltopdf-0.12.3",
    ordering: 220,
    technotype: wkhtml,
    hiera: "pm::tool::wkhtmltopdf::major: '0.12'
pm::tool::wkhtmltopdf::minor: '3'",
    puppetclass: "pm::tool::wkhtmltopdf",
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Wkhtmltopdf
      shell: test -x /usr/bin/wkhtmltopdf >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_imagick =
  Techno.create!(
    name: "imagick",
    ordering: 220,
    technotype: imagick,
    hiera: "",
    puppetclass: "pm::tool::imagemagick",
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Imagemagick
      shell: test -x /usr/bin/convert >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_apache =
  Techno.create!(
    name: "apache",
    puppetclass: "pm::http",
    ordering: 160,
    technotype: wserver,
    hiera: "iswebserver: 1",
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Apache
      shell: ps aux | grep /usr/sbin/apache2 | grep -v grep >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_rabbitmq =
  Techno.create!(
    name: "rabbitmq",
    puppetclass: "pm::rabbit",
    ordering: 60,
    technotype: messaging,
    hiera: "",
    dockercompose: '%%CONTAINERNAME%%:
  image: rabbitmq:3
  container_name: %%CONTAINERNAME%%',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check RabbitMQ
      shell: nmap 127.0.0.1 -p 5672 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_elasticsearch =
  Techno.create!(
    name: "elasticsearch",
    puppetclass: "pm::elastic",
    ordering: 40,
    technotype: index,
    hiera: "",
    dockercompose: '%%CONTAINERNAME%%:
  image: elasticsearch:1.5
  container_name: %%CONTAINERNAME%%
  volumes:
    - %%TECHNOFOLDER%%:/usr/share/elasticsearch/data
  command: elasticsearch -Des.network.bind_host=0.0.0.0',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check ElasticSearch
      shell: nmap 127.0.0.1 -p 9300 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_memcached =
  Techno.create!(
    name: "memcached",
    puppetclass: "pm::nosql::memcache",
    ordering: 100,
    technotype: keyvalue,
    hiera: "iscache: 1",
    dockercompose: '%%CONTAINERNAME%%:
  image: memcached:1.4
  container_name: %%CONTAINERNAME%%',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Memcached
      shell: nmap 127.0.0.1 -p 11211 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_redis =
  Techno.create!(
    name: "redis",
    puppetclass: "pm::nosql::redis",
    ordering: 80,
    technotype: keyvalue,
    hiera: "",
    dockercompose: '%%CONTAINERNAME%%:
  image: redis:3
  container_name: %%CONTAINERNAME%%',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Redis
      shell: nmap 127.0.0.1 -p 6379 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_varnish =
  Techno.create!(
    name: "varnish",
    puppetclass: "pm::varnish",
    ordering: 200,
    technotype: cache,
    hiera: "",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Varnish
      shell: nmap 127.0.0.1 -p 80 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_mysql =
  Techno.create!(
    name: "mysql",
    puppetclass: "pm::sql",
    ordering: 70,
    technotype: bdd,
    hiera: "ismysql: 1",
    dockercompose: '%%CONTAINERNAME%%:
  container_name: %%CONTAINERNAME%%
  volumes:
    - %%TECHNOFOLDER%%:/var/lib/mysql
  image: mariadb
  environment:
    MYSQL_ROOT_PASSWORD: 8to9or1',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Mysql
      shell: nmap 127.0.0.1 -p 3306 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_nodejs010 =
  Techno.create!(
    name: "nodejs-0.10",
    puppetclass: "pm::nodejs",
    ordering: 140,
    technotype: node,
    hiera: "node_version: 0.10",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Node Binary
      shell: test -x /usr/bin/node >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_nodejs012 =
  Techno.create!(
    name: "nodejs-0.12",
    puppetclass: "pm::nodejs",
    ordering: 140,
    technotype: node,
    hiera: "node_version: 0.12",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Node Binary
      shell: test -x /usr/bin/node >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_nodejs =
  Techno.create!(
    name: "nodejs-4",
    puppetclass: "pm::nodejs",
    ordering: 140,
    technotype: node,
    hiera: "node_version: 4.x",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Node Binary
      shell: test -x /usr/bin/node >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_nodejs5 =
  Techno.create!(
    name: "nodejs-5",
    puppetclass: "pm::nodejs",
    ordering: 140,
    technotype: node,
    hiera: "node_version: 5.x",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Node Binary
      shell: test -x /usr/bin/node >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_nodejs6 =
  Techno.create!(
    name: "nodejs-6",
    puppetclass: "pm::nodejs",
    ordering: 140,
    technotype: node,
    hiera: "node_version: 6.x",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Node Binary
      shell: test -x /usr/bin/node >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_mongodb =
  Techno.create!(
    name: "mongodb-2.6",
    puppetclass: "pm::nosql::mongo",
    ordering: 40,
    technotype: bigdata,
    hiera: "ismongo: 1
mongodb::globals::version: '2.6.11'",
    dockercompose: '%%CONTAINERNAME%%:
  image: mongo:2.6
  container_name: %%CONTAINERNAME%%
  volumes:
    - %%TECHNOFOLDER%%:/data/db
',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check MongoDB
      shell: nmap 127.0.0.1 -p 27017 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_mongodb3 =
  Techno.create!(
    name: "mongodb-3.0",
    puppetclass: "pm::nosql::mongo",
    ordering: 40,
    technotype: bigdata,
    hiera: "ismongo: 1
mongodb::globals::version: '3.0.7'",
    dockercompose: '%%CONTAINERNAME%%:
  image: mongo:3.0
  container_name: %%CONTAINERNAME%%
  volumes:
    - %%TECHNOFOLDER%%:/data/db
',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check MongoDB
      shell: nmap 127.0.0.1 -p 27017 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_mongodb32 =
  Techno.create!(
    name: "mongodb-3.2",
    puppetclass: "pm::nosql::mongo",
    ordering: 40,
    technotype: bigdata,
    hiera: "ismongo: 1
mongodb::globals::version: '3.2.0'",
    dockercompose: '%%CONTAINERNAME%%:
  image: mongo:3.2
  container_name: %%CONTAINERNAME%%
  volumes:
    - %%TECHNOFOLDER%%:/data/db
',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check MongoDB
      shell: nmap 127.0.0.1 -p 27017 | grep open >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_java6 =
  Techno.create!(
    name: "java-6",
    puppetclass: "pm::java",
    ordering: 20,
    technotype: java,
    hiera: "pm::java::version: '6'",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Java Binary
      shell: test -x /usr/bin/java >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_java7 =
  Techno.create!(
    name: "java-7",
    puppetclass: "pm::java",
    ordering: 20,
    technotype: java,
    hiera: "pm::java::version: '7'",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Java Binary
      shell: test -x /usr/bin/java >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

techno_java8 =
  Techno.create!(
    name: "java-8",
    puppetclass: "pm::java",
    ordering: 20,
    technotype: java,
    hiera: "pm::java::version: '8'",
    dockercompose: '',
    playbook: '- hosts: all
  gather_facts: False
  tasks:
    - name: Check Java Binary
      shell: test -x /usr/bin/java >/dev/null 2>&1 && echo -en 1 || echo -en 0
      args:
        executable: /bin/bash
      register: check
      ignore_errors: True
    - name: Output probe
      debug: msg="ndeploy:{{ inventory_hostname }}:{{ check.stdout }}"'
  )

puts "Created #{Techno.count} technos"

# Brand import rows
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

admin =
  User.create!(
    email: 'usera@os.nextdeploy',
    firstname: 'usera',
    lastname: 'usera',
    company: 'My Company',
    is_project_create: true,
    is_user_create: true,
    is_recv_vms: false,
    quotavm: 0,
    quotaprod: 0,
    password: 'word123123',
    password_confirmation: 'word123123',
    group: admin_g,
    layout: 'us'
  )

user_lead =
  User.create!(
    email: 'userl@os.nextdeploy',
    firstname: 'userl',
    lastname: 'userl',
    company: 'My Company',
    is_project_create: true,
    is_user_create: true,
    is_recv_vms: false,
    quotavm: 10,
    quotaprod: 4,
    password: 'word123123',
    password_confirmation: 'word123123',
    group: lead_g,
    layout: 'us'
  )

user_dev =
  User.create!(
    email: 'userd@os.nextdeploy',
    firstname: 'userd',
    lastname: 'userd',
    company: 'My Company',
    is_project_create: false,
    is_user_create: false,
    is_recv_vms: false,
    quotavm: 5,
    quotaprod: 0,
    password: 'word123123',
    password_confirmation: 'word123123',
    group: dev_g,
    layout: 'us'
  )

user_pm =
  User.create!(
    email: 'userp@os.nextdeploy',
    firstname: 'userp',
    lastname: 'userp',
    company: 'My Company',
    is_project_create: false,
    is_user_create: false,
    is_recv_vms: false,
    quotavm: 5,
    quotaprod: 0,
    password: 'word123123',
    password_confirmation: 'word123123',
    group: pm_g,
    layout: 'us'
  )

user_g =
  User.create!(
    email: 'userg@os.nextdeploy',
    firstname: 'userg',
    lastname: 'userg',
    company: 'My Company',
    is_project_create: false,
    is_user_create: false,
    is_recv_vms: false,
    quotavm: 3,
    quotaprod: 0,
    password: 'word123123',
    password_confirmation: 'word123123',
    group: guest_g,
    layout: 'us'
  )

puts "Created #{User.count} users"

# HACK Ugly ... Commands to get glance_id generated just before during glance installation
image_show_cmd = 'glance --os-username user --os-password wordpass --os-tenant-name tenant0 ' +
                 '--os-image-api-version 1 --os-auth-url http://controller-m:35357/v2.0 image-show'

glance_id_j = %x(#{image_show_cmd} osvm-jessie | grep "id" | sed "s; [^ ]*$;;" | sed "s;^.* ;;")
glance_id_j.strip!

glance_id_t = %x(#{image_show_cmd} osvm-trusty | grep "id" | sed "s; [^ ]*$;;" | sed "s;^.* ;;")
glance_id_t.strip!

glance_id_x = %x(#{image_show_cmd} osvm-xenial | grep "id" | sed "s; [^ ]*$;;" | sed "s;^.* ;;")
glance_id_x.strip!

ubuntu14 =
  Systemimage.create!(
    name: 'Ubuntu1404',
    glance_id: glance_id_t,
    enabled: true,
    systemimagetype: linux
  )

debian8 =
  Systemimage.create!(
    name: 'Debian8',
    glance_id: glance_id_j,
    enabled: true,
    systemimagetype: linux
  )

ubuntu16 =
  Systemimage.create!(
    name: 'Ubuntu1604',
    glance_id: glance_id_x,
    enabled: true,
    systemimagetype: linux
  )

puts "Create #{Systemimage.count} system image"

# Project import rows
project_drupal =
  Project.create!(
    name: "www.drupalmycompany.com",
    brand: brand_cust1,
    gitpath: "mycompany-www-drupalmycompany-com",
    systemimages: [ubuntu14, debian8],
    enabled: true,
    login: "modem",
    password: "modem",
    is_ht: false,
    owner: admin,
    vmsizes: [flavor_tiny, flavor_small],
    users: [admin, user_lead, user_dev, user_pm, user_g],
    technos: [
     techno_varnish,
     techno_nodejs,
     techno_apache,
     techno_mysql
    ]
  )

project_symfony_c =
  Project.create!(
    name: "www.symfonyyourcompany.com",
    systemimages: [ubuntu14],
    brand: brand_cust2,
    login: "modem",
    password: "modem",
    owner: admin,
    vmsizes: [flavor_tiny, flavor_small],
    gitpath: "yourcompany-www-symfonyyourcompany-com",
    enabled: true,
    is_ht: false,
    users: [admin, user_dev, user_g],
    technos: [
      techno_varnish,
      techno_nodejs,
      techno_apache,
      techno_mongodb,
      techno_redis,
      techno_rabbitmq,
      techno_elasticsearch
    ]
  )

project_symfony_s =
  Project.create!(
    name: "www.symfonyhiscompany.com",
    systemimages: [ubuntu14, debian8],
    brand: brand_cust3,
    login: "modem",
    password: "modem",
    owner: admin,
    vmsizes: [flavor_tiny],
    gitpath: "hiscompany-www-symfonyhiscompany-com",
    enabled: true,
    is_ht: false,
    users: [admin, user_dev],
    technos: [
      techno_varnish,
      techno_nodejs,
      techno_apache,
      techno_mysql,
      techno_redis
    ]
  )

project_no =
  Project.create!(
    name: "www.statichiscompany.com",
    systemimages: [ubuntu14],
    brand: brand_cust3,
    login: "modem",
    password: "modem",
    owner: admin,
    vmsizes: [flavor_tiny],
    users: [admin, user_lead, user_dev],
    gitpath: "hiscompany-www-statichiscompany-com",
    enabled: true,
    is_ht: false,
    technos: [techno_varnish, techno_nodejs, techno_apache]
  )

project_wordpress =
  Project.create!(
    name: "www.wordpressmycompany.com",
    systemimages: [ubuntu14, debian8],
    brand: brand_cust1,
    login: "modem",
    password: "modem",
    owner: admin,
    vmsizes: [flavor_tiny, flavor_small],
    users: [admin, user_lead, user_g],
    gitpath: "mycompany-www-wordpressmycompany-com",
    enabled: true,
    is_ht: false,
    technos: [techno_varnish, techno_nodejs, techno_apache, techno_mysql]
  )

project_njs =
  Project.create!(
    name: "www.njsyourcompany.com",
    systemimages: [ubuntu16],
    brand: brand_cust2,
    login: "modem",
    password: "modem",
    owner: admin,
    vmsizes: [flavor_tiny],
    users: [admin, user_lead, user_dev],
    gitpath: "yourcompany-www-njsyourcompany-com",
    enabled: true,
    is_ht: false,
    technos: [techno_varnish, techno_nodejs]
  )

puts "Created #{Project.count} projects"

ep_njs =
  Endpoint.create!(
    framework: framework_nodejs,
    project: project_njs,
    prefix: "",
    path: "nodejs",
    envvars: "PORT=3100",
    aliases: "nodejs njs",
    port: 3100,
    ipfilter: '',
    customvhost: '',
    is_sh: false,
    is_import: false,
    is_main: true
  )
ep_njs.install_endpoint

ep_wp =
  Endpoint.create!(
    framework: framework_wordpress,
    project: project_wordpress,
    prefix: "",
    path: "server",
    envvars: "",
    aliases: "",
    port: 8080,
    ipfilter: '',
    customvhost: '',
    is_sh: false,
    is_import: true,
    is_main: true
  )
ep_wp.install_endpoint

ep_wp_html =
  Endpoint.create!(
    framework: framework_no,
    project: project_wordpress,
    prefix: "html",
    path: "html",
    envvars: "",
    aliases: "",
    port: 8080,
    ipfilter: '',
    customvhost: '',
    is_sh: false,
    is_import: false,
    is_main: false
  )
ep_wp_html.install_endpoint

ep_static =
  Endpoint.create!(
    framework: framework_no,
    project: project_no,
    prefix: "",
    path: "server",
    envvars: "",
    aliases: "",
    port: 8080,
    ipfilter: '',
    customvhost: '',
    is_sh: false,
    is_import: false,
    is_main: true
  )
ep_static.install_endpoint

ep_drupal =
  Endpoint.create!(
    framework: framework_drupal8,
    project: project_drupal,
    prefix: "",
    path: "server",
    envvars: "",
    aliases: "",
    port: 8080,
    ipfilter: '',
    customvhost: '',
    is_sh: false,
    is_import: true,
    is_main: true
  )
ep_drupal.install_endpoint

ep_sf2s =
  Endpoint.create!(
    framework: framework_sf2,
    project: project_symfony_s,
    prefix: "",
    path: "server",
    envvars: "",
    aliases: "sf2s",
    port: 8080,
    ipfilter: '',
    customvhost: '',
    is_sh: false,
    is_import: true,
    is_main: true
  )
ep_sf2s.install_endpoint

ep_sf3c =
  Endpoint.create!(
    framework: framework_sf3,
    project: project_symfony_c,
    prefix: "",
    path: "server",
    envvars: "",
    aliases: "sf3c",
    port: 8080,
    ipfilter: '',
    customvhost: '',
    is_sh: false,
    is_import: true,
    is_main: true
  )
ep_sf3c.install_endpoint

puts "Created #{Endpoint.count} endpoints"


twitter_msg =
  Hpmessage.create!(
    title: '@NextDeploy',
    message: '<a class="twitter-timeline" href="https://twitter.com/nextdeploy" ' +
             'data-widget-id="690883407518273536">Tweets by @nextdeploy</a>',
    expiration: '0',
    is_twitter: 1,
    access_level_min: 20,
    access_level_max: 50,
    ordering: -100,
  )

puts "Create #{Hpmessage.count} messages"
